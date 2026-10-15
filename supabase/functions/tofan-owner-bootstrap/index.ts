import { createClient } from "npm:@supabase/supabase-js@2";

const jsonHeaders = { "content-type": "application/json; charset=utf-8" };

function reply(status: number, body: Record<string, unknown>): Response {
  return new Response(JSON.stringify(body), { status, headers: jsonHeaders });
}

async function digest(value: string): Promise<Uint8Array> {
  return new Uint8Array(
    await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value)),
  );
}

async function constantTimeEqual(a: string, b: string): Promise<boolean> {
  // Hash first so the comparison loop always processes fixed-length values.
  const [left, right] = await Promise.all([digest(a), digest(b)]);
  let difference = 0;
  for (let i = 0; i < left.length; i++) difference |= left[i] ^ right[i];
  return difference === 0;
}

Deno.serve(async (req: Request): Promise<Response> => {
  if (req.method !== "POST") {
    return reply(405, { error: "method_not_allowed" });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  const bootstrapSecret = Deno.env.get("TOFAN_OWNER_BOOTSTRAP_SECRET") ?? "";

  // Fail closed when any required server-only configuration is missing or weak.
  if (
    !supabaseUrl || !anonKey || !serviceRoleKey ||
    bootstrapSecret.length < 32
  ) {
    return reply(503, { error: "owner_bootstrap_not_configured" });
  }

  const authorization = req.headers.get("authorization") ?? "";
  const match = authorization.match(/^Bearer\\s+(.+)$/i);
  if (!match) return reply(401, { error: "authentication_required" });

  const authClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await authClient.auth.getUser(
    match[1],
  );
  if (userError || !userData.user) {
    return reply(401, { error: "invalid_authentication" });
  }

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return reply(400, { error: "invalid_json" });
  }
  if (
    typeof body !== "object" || body === null ||
    !("bootstrapSecret" in body) ||
    typeof (body as { bootstrapSecret: unknown }).bootstrapSecret !== "string"
  ) {
    return reply(400, { error: "invalid_request" });
  }

  const suppliedSecret = (body as { bootstrapSecret: string }).bootstrapSecret;
  if (
    suppliedSecret.length < 32 ||
    !(await constantTimeEqual(suppliedSecret, bootstrapSecret))
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
    // Do not expose database details or secret material to the client.
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
