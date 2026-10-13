// TOFAN ID — trusted manual-review endpoint.
// Only accounts whose server-managed Supabase app_metadata contains
// identity_reviewer: true may review requests. Never use user_metadata for this.
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

const rejectionCodes = new Set([
  "document_unreadable",
  "document_expired",
  "document_not_supported",
  "identity_mismatch",
  "manual_review_failed",
  "other_review_required",
]);

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return json(503, { error: "identity_review_not_configured" });
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

  const requestId = body.request_id;
  const decision = body.decision;
  const reasonCode = body.reason_code;
  if (typeof requestId !== "string" ||
      !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(requestId) ||
      (decision !== "verified" && decision !== "rejected") ||
      (decision === "verified" && reasonCode != null) ||
      (decision === "rejected" &&
        (typeof reasonCode !== "string" || !rejectionCodes.has(reasonCode)))) {
    return json(400, { error: "invalid_review_request" });
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${match[1]}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: userError } = await userClient.auth.getUser(match[1]);
  if (userError || !userData.user) return json(401, { error: "invalid_session" });

  // app_metadata is managed by trusted server/admin tooling; user_metadata is
  // editable by the user and is intentionally never consulted for authorization.
  if (userData.user.app_metadata?.identity_reviewer !== true) {
    return json(403, { error: "identity_reviewer_required" });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: pending, error: readError } = await admin
    .from("identity_verification_requests")
    .select("id,user_id,method,status")
    .eq("id", requestId)
    .eq("status", "pending_review")
    .maybeSingle();
  if (readError) return json(503, { error: "identity_review_storage_unavailable" });
  if (!pending) return json(404, { error: "pending_review_not_found" });
  if (pending.user_id === userData.user.id) {
    return json(403, { error: "self_review_not_allowed" });
  }
  if (pending.method !== "manual_document_review") {
    return json(409, { error: "unsupported_review_method" });
  }

  const now = new Date().toISOString();
  const update = decision === "verified"
    ? {
        status: "verified",
        assurance_level: "document_reviewed",
        reviewer_actor_id: userData.user.id,
        reviewed_at: now,
        reason_code: null,
      }
    : {
        status: "rejected",
        assurance_level: "none",
        reviewer_actor_id: userData.user.id,
        reviewed_at: now,
        reason_code: reasonCode,
      };

  // Compare-and-set ensures only one reviewer can transition a pending request.
  const { data: reviewed, error: updateError } = await admin
    .from("identity_verification_requests")
    .update(update)
    .eq("id", requestId)
    .eq("status", "pending_review")
    .select("id,user_id,status,method,assurance_level,reviewer_actor_id,reviewed_at,reason_code")
    .maybeSingle();
  if (updateError) return json(503, { error: "identity_review_update_failed" });
  if (!reviewed) return json(409, { error: "review_already_completed" });

  // Return metadata only. Never return or log identity documents or OCR payloads.
  return json(200, { status: "review_completed", record: reviewed });
});
