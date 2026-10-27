import { createClient } from "npm:@supabase/supabase-js@2";
import {
  constantTimeSecretMatch,
  extractBearerToken,
  hasStrongBootstrapSecret,
  isBootstrapSecretBody,
  isExpectedBootstrapUser,
} from "./security.ts";

const jsonHeaders = { "content-type": "application/json; charset=utf-8" };

function reply(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: jsonHeaders });
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") {
    return reply(405, { error: "method_not_allowed" });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? Deno.env.get("SUPABASE_SECRET_KEY") ?? "";
  const bootstrapSecret = Deno.env.get("TOFAN_OWNER_BOOTSTRAP_SECRET") ?? "";
  // Set out-of-band to the exact Auth UUID approved by the deployment operator.
  const expectedOwnerUserId = Deno.env.get("TOFAN_OWNER_BOOTSTRAP_USER_ID") ?? "";

  // Fail closed unless all required server-only configuration is present.
  if (
    !supabaseUrl || !anonKey || !serviceRoleKey ||
    !hasStrongBootstrapSecret(bootstrapSecret) ||
    !expectedOwnerUserId
  ) {
    return reply(503, { error: "owner_bootstrap_not_configured" });
  }

  const accessToken = extractBearerToken(req.headers.get("authorization"));
  if (!accessToken) return reply(401, { error: "authentication_required" });

  const authClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await authClient.auth.getUser(accessToken);
  if (userError || !userData.user) {
    return reply(401, { error: "invalid_authentication" });
  }

  // Bind bootstrap to one operator-approved Auth user; the shared secret alone
  // must never allow another authenticated account to claim the owner slot.
  if (!isExpectedBootstrapUser(userData.user.id, expectedOwnerUserId)) {
    return reply(403, { error: "bootstrap_rejected" });
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return reply(400, { error: "invalid_json" });
  }
  if (!isBootstrapSecretBody(body)) {
    return reply(400, { error: "invalid_request" });
  }

  const suppliedSecret = body.bootstrapSecret;
  if (
    !hasStrongBootstrapSecret(suppliedSecret) ||
    !(await constantTimeSecretMatch(suppliedSecret, bootstrapSecret))
  ) {
    // Never log or return either secret.
    return reply(403, { error: "bootstrap_rejected" });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error } = await admin.rpc("consume_tofan_owner_bootstrap", {
    p_user_id: userData.user.id,
  });

  if (error) {
    console.error("TOFAN owner bootstrap RPC failed", { code: error.code });
    return reply(503, { error: "owner_bootstrap_unavailable" });
  }
  if (data !== true) {
    return reply(409, { error: "owner_bootstrap_unavailable_or_consumed" });
  }

  return reply(200, {
    status: "owner_assigned",
    userId: userData.user.id,
    note: "Server bootstrap consumed once. This does not itself verify legal identity.",
  });
});
