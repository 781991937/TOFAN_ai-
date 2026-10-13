#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL must point to a disposable PostgreSQL test database}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;

create schema auth;
create table auth.users (
  id uuid primary key
);

-- Minimal Supabase-compatible auth.uid() fixture for RLS tests.
-- CI uses only synthetic IDs and a disposable PostgreSQL service.
create function auth.uid()
returns uuid
language sql
stable
as $function$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$function$;
SQL

for migration in supabase/migrations/*.sql; do
  echo "Applying $migration"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$migration"
done

echo "Running identity-verification RLS assertions"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/identity_verification_rls.sql

echo "Running owner-bootstrap authorization and single-use assertions"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/tofan_owner_bootstrap.sql

echo "Running passkey storage and step-up receipt assertions"
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/tests/tofan_passkey_step_up.sql

expect_failure() {
  local description="$1"
  local expected_text="$2"
  local statement="$3"
  local log_file
  log_file="$(mktemp)"
  if psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "$statement" >"$log_file" 2>&1; then
    echo "FAIL: $description unexpectedly succeeded"
    cat "$log_file"
    rm -f "$log_file"
    exit 1
  fi
  if ! grep -qi "$expected_text" "$log_file"; then
    echo "FAIL: $description failed for an unexpected reason"
    cat "$log_file"
    rm -f "$log_file"
    exit 1
  fi
  echo "PASS: $description"
  rm -f "$log_file"
}

expect_failure \
  "client cannot create a trusted-provider verification request" \
  "row-level security" \
  "SET ROLE authenticated; SET request.jwt.claim.sub = '33333333-3333-4333-8333-333333333333'; INSERT INTO public.identity_verification_requests (user_id, method) VALUES ('33333333-3333-4333-8333-333333333333', 'trusted_provider')"

expect_failure \
  "client cannot set verification status during insert" \
  "permission denied" \
  "SET ROLE authenticated; SET request.jwt.claim.sub = '33333333-3333-4333-8333-333333333333'; INSERT INTO public.identity_verification_requests (user_id, method, status) VALUES ('33333333-3333-4333-8333-333333333333', 'manual_document_review', 'verified')"

expect_failure \
  "client cannot update verification decisions" \
  "permission denied" \
  "SET ROLE authenticated; SET request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111'; UPDATE public.identity_verification_requests SET status = 'verified' WHERE user_id = '11111111-1111-4111-8111-111111111111'"

expect_failure \
  "duplicate pending requests are rejected" \
  "idx_identity_verification_one_pending_per_user" \
  "SET ROLE authenticated; SET request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111'; INSERT INTO public.identity_verification_requests (user_id, method) VALUES ('11111111-1111-4111-8111-111111111111', 'manual_document_review')"

echo "PASS: all migrations and identity-verification RLS checks completed"
