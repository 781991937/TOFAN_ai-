// TOFAN AI — one-time initial owner bootstrap.
// Configure TOFAN_OWNER_BOOTSTRAP_SECRET as a high-entropy Supabase Edge Function secret.
// This endpoint never logs or persists the supplied secret and never accepts an actor ID
// from the request body; the actor comes from a validated Supabase access token.
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function response(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function constantTimeEqual(a: string, b: string): boolean {
  const encoder = new TextEncoder();
  const left = encoder.encode(a);
  const right = encoder.encode(b);
  let difference = left.length ^ right.length;
  const length = Math.max(left.length, right.length);
  for (let i = 0; i < length; i++) {
    difference |= (left[i] ?? 0) ^ (right[i] ?? 0);
  }
  return difference === 0;
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return response(405, { error: "method_not_allowed" });
  }

  const bootstrapSecret = Deno.env.get("TOFAN_OWNER_BOOTSTRAP_SECRET");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!bootstrapSecret || bootstrapSecret.length < 32 || !supabaseUrl ||
      !anonKey || !serviceRoleKey) {
    return response(503, { error: "owner_bootstrap_not_configured" });
  }

  const authorization = request.headers.get("Authorization") ?? "";
  const match = authorization.match(/^Bearer\s+(.+)$/i);
  if (!match) return response(401, { error: "authentication_required" });

  let body: { bootstrap_secret?: unknown };
  try {
    body = await request.json();
  } catch {
    return response(400, { error: "invalid_json" });
  }
  if (typeof body.bootstrap_secret !== "string" ||
      !constantTimeEqual(body.bootstrap_secret, bootstrapSecret)) {
    return response(403, { error: "bootstrap_denied" });
  }

  // Validate the token with Supabase Auth; do not trust decoded JWT claims.
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${match[1]}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser(match[1]);
  if (userError || !userData.user) {
    return response(401, { error: "invalid_session" });
  }

  // The service key remains server-side. The SQL function atomically enforces
  // one-time use and requires a previously reviewed identity-verification record.
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await admin.rpc("claim_initial_tofan_owner", {
    p_actor_id: userData.user.id,
  });
  if (error) {
    const message = error.message ?? "";
    if (message.includes("identity verification is required")) {
      return response(403, { error: "verified_identity_required" });
    }
    if (message.includes("already consumed or unavailable") ||
        error.code === "23505") {
      return response(409, { error: "owner_bootstrap_unavailable" });
    }
    // Do not disclose database internals to the caller.
    return response(500, { error: "owner_bootstrap_failed" });
  }

  return response(200, {
    status: "owner_assigned",
    owner_user_id: userData.user.id,
    assignment: Array.isArray(data) ? data[0] : data,
  });
});
