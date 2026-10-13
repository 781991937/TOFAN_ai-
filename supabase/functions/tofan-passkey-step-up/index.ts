import {
  generateAuthenticationOptions,
  generateRegistrationOptions,
  verifyAuthenticationResponse,
  verifyRegistrationResponse,
  type AuthenticationResponseJSON,
  type AuthenticatorTransport,
  type RegistrationResponseJSON,
} from "npm:@simplewebauthn/server@14.0.3";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const challengeLifetimeMs = 5 * 60 * 1000;
const stepUpLifetimeMs = 2 * 60 * 1000;

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.length; i += 1) binary += String.fromCharCode(bytes[i]);
  return btoa(binary);
}

function base64ToBytes(value: string): Uint8Array {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

function base64Url(bytes: Uint8Array): string {
  return bytesToBase64(bytes).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function sha256Hex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return Array.from(new Uint8Array(digest), (byte) => byte.toString(16).padStart(2, "0")).join("");
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const rpID = Deno.env.get("TOFAN_WEBAUTHN_RP_ID");
  const configuredOrigins = Deno.env.get("TOFAN_WEBAUTHN_ORIGIN") ?? "";
  // Exact allowlist: web origins use https://..., Android native credentials
  // use android:apk-key-hash:<base64url SHA-256 signing-certificate hash>.
  const expectedOrigins = configuredOrigins.split(",").map((origin) => origin.trim()).filter(Boolean);
  if (!supabaseUrl || !anonKey || !serviceRoleKey || !rpID || expectedOrigins.length === 0) {
    return json(503, { error: "passkey_service_not_configured" });
  }

  const authorization = request.headers.get("Authorization") ?? "";
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) return json(401, { error: "authentication_required" });

  let body: Record<string, unknown>;
  try {
    const parsed: unknown = await request.json();
    if (!isObject(parsed)) return json(400, { error: "invalid_json" });
    body = parsed;
  } catch {
    return json(400, { error: "invalid_json" });
  }

  const action = body.action;
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${match[1]}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser(match[1]);
  if (userError || !userData.user) return json(401, { error: "invalid_session" });
  const user = userData.user;

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  if (action === "registration-options") {
    const { data: existing, error } = await admin
      .from("tofan_passkey_credentials")
      .select("credential_id,transports")
      .eq("user_id", user.id);
    if (error) return json(500, { error: "passkey_storage_unavailable" });

    const options = await generateRegistrationOptions({
      rpName: "TOFAN AI",
      rpID,
      userID: new TextEncoder().encode(user.id),
      userName: user.email ?? user.id,
      attestationType: "none",
      authenticatorSelection: {
        residentKey: "preferred",
        userVerification: "required",
      },
      excludeCredentials: (existing ?? []).map((row) => ({
        id: row.credential_id,
        transports: (row.transports ?? []) as AuthenticatorTransport[],
      })),
    });

    const expiresAt = new Date(Date.now() + challengeLifetimeMs).toISOString();
    const { data: challenge, error: challengeError } = await admin
      .from("tofan_passkey_challenges")
      .insert({
        user_id: user.id,
        ceremony: "registration",
        challenge: options.challenge,
        expires_at: expiresAt,
      })
      .select("id")
      .single();
    if (challengeError || !challenge) return json(500, { error: "challenge_storage_failed" });
    return json(200, { challenge_id: challenge.id, options });
  }

  if (action === "registration-verify" || action === "authentication-verify") {
    const challengeId = body.challenge_id;
    const credentialResponse = body.response;
    if (typeof challengeId !== "string" || !isObject(credentialResponse)) {
      return json(400, { error: "invalid_ceremony_response" });
    }
    const ceremony = action === "registration-verify" ? "registration" : "authentication";
    const { data: challenge, error: challengeReadError } = await admin
      .from("tofan_passkey_challenges")
      .select("id,challenge,expires_at,consumed_at")
      .eq("id", challengeId)
      .eq("user_id", user.id)
      .eq("ceremony", ceremony)
      .maybeSingle();
    if (challengeReadError || !challenge || challenge.consumed_at ||
        new Date(challenge.expires_at).getTime() <= Date.now()) {
      return json(400, { error: "challenge_expired_or_invalid" });
    }

    // Consume before cryptographic verification; even failed attempts cannot replay the challenge.
    const { data: consumed, error: consumeError } = await admin
      .from("tofan_passkey_challenges")
      .update({ consumed_at: new Date().toISOString() })
      .eq("id", challengeId)
      .eq("user_id", user.id)
      .eq("ceremony", ceremony)
      .is("consumed_at", null)
      .gt("expires_at", new Date().toISOString())
      .select("id")
      .maybeSingle();
    if (consumeError || !consumed) return json(409, { error: "challenge_already_used" });

    if (action === "registration-verify") {
      let verification;
      try {
        verification = await verifyRegistrationResponse({
          response: credentialResponse as unknown as RegistrationResponseJSON,
          expectedChallenge: challenge.challenge,
          expectedOrigin: expectedOrigins,
          expectedRPID: rpID,
          requireUserVerification: true,
        });
      } catch {
        return json(400, { error: "passkey_registration_verification_failed" });
      }
      if (!verification.verified || !verification.registrationInfo?.credential) {
        return json(400, { error: "passkey_registration_not_verified" });
      }

      const info = verification.registrationInfo;
      const credential = info.credential;
      const { error: insertError } = await admin.from("tofan_passkey_credentials").insert({
        credential_id: credential.id,
        user_id: user.id,
        public_key_base64: bytesToBase64(credential.publicKey),
        sign_count: credential.counter,
        transports: credential.transports ?? [],
        device_type: info.credentialDeviceType,
        backed_up: info.credentialBackedUp,
      });
      if (insertError) return json(409, { error: "passkey_already_registered_or_storage_failed" });
      return json(200, { status: "passkey_registered", user_verification_required: true });
    }

    if (typeof credentialResponse.id !== "string") {
      return json(400, { error: "credential_id_required" });
    }
    const { data: stored, error: storedError } = await admin
      .from("tofan_passkey_credentials")
      .select("credential_id,user_id,public_key_base64,sign_count,transports")
      .eq("credential_id", credentialResponse.id)
      .eq("user_id", user.id)
      .maybeSingle();
    if (storedError || !stored) return json(401, { error: "passkey_not_registered_for_account" });

    const previousCounter = Number(stored.sign_count);
    if (!Number.isSafeInteger(previousCounter) || previousCounter < 0) {
      return json(500, { error: "credential_counter_invalid" });
    }

    let verification;
    try {
      verification = await verifyAuthenticationResponse({
        response: credentialResponse as unknown as AuthenticationResponseJSON,
        expectedChallenge: challenge.challenge,
        expectedOrigin: expectedOrigins,
        expectedRPID: rpID,
        credential: {
          id: stored.credential_id,
          publicKey: Uint8Array.from(base64ToBytes(stored.public_key_base64)),
          counter: previousCounter,
          transports: (stored.transports ?? []) as AuthenticatorTransport[],
        },
        requireUserVerification: true,
      });
    } catch {
      return json(401, { error: "passkey_authentication_verification_failed" });
    }
    if (!verification.verified) return json(401, { error: "passkey_authentication_not_verified" });

    const { error: counterError } = await admin
      .from("tofan_passkey_credentials")
      .update({
        sign_count: verification.authenticationInfo.newCounter,
        last_used_at: new Date().toISOString(),
      })
      .eq("credential_id", stored.credential_id)
      .eq("user_id", user.id);
    if (counterError) return json(500, { error: "credential_update_failed" });

    const { data: owner, error: ownerError } = await admin
      .from("tofan_owner_assignment")
      .select("owner_user_id")
      .eq("singleton", true)
      .eq("owner_user_id", user.id)
      .maybeSingle();
    if (ownerError) return json(500, { error: "owner_status_unavailable" });
    if (!owner) return json(403, { error: "owner_step_up_only" });

    // Opaque one-time receipt; only its hash is persisted. A privileged server
    // operation must consume it via consume_tofan_owner_step_up before acting.
    const rawToken = base64Url(crypto.getRandomValues(new Uint8Array(32)));
    const tokenHash = await sha256Hex(rawToken);
    const { error: grantError } = await admin.from("tofan_owner_step_up_grants").insert({
      token_hash: tokenHash,
      user_id: user.id,
      scope: "owner_operation",
      expires_at: new Date(Date.now() + stepUpLifetimeMs).toISOString(),
    });
    if (grantError) return json(500, { error: "step_up_grant_creation_failed" });
    return json(200, {
      status: "step_up_verified",
      step_up_token: rawToken,
      expires_in_seconds: stepUpLifetimeMs / 1000,
      scope: "owner_operation",
    });
  }

  if (action === "authentication-options") {
    const { data: credentials, error } = await admin
      .from("tofan_passkey_credentials")
      .select("credential_id,transports")
      .eq("user_id", user.id);
    if (error) return json(500, { error: "passkey_storage_unavailable" });
    if (!credentials?.length) return json(404, { error: "no_passkeys_registered" });

    const options = await generateAuthenticationOptions({
      rpID,
      allowCredentials: credentials.map((row) => ({
        id: row.credential_id,
        transports: (row.transports ?? []) as AuthenticatorTransport[],
      })),
      userVerification: "required",
    });
    const { data: challenge, error: challengeError } = await admin
      .from("tofan_passkey_challenges")
      .insert({
        user_id: user.id,
        ceremony: "authentication",
        challenge: options.challenge,
        expires_at: new Date(Date.now() + challengeLifetimeMs).toISOString(),
      })
      .select("id")
      .single();
    if (challengeError || !challenge) return json(500, { error: "challenge_storage_failed" });
    return json(200, { challenge_id: challenge.id, options });
  }

  return json(400, { error: "unsupported_action" });
});
