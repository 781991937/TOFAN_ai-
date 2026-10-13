\set ON_ERROR_STOP on

-- These are synthetic fixtures only; never use real identity records in CI.
insert into auth.users (id) values
  ('11111111-1111-4111-8111-111111111111'),
  ('22222222-2222-4222-8222-222222222222'),
  ('33333333-3333-4333-8333-333333333333');

-- Seed another user's row as the database owner to test cross-user isolation.
insert into public.identity_verification_requests (user_id, method)
values ('22222222-2222-4222-8222-222222222222', 'manual_document_review');

set role authenticated;
set request.jwt.claim.sub = '11111111-1111-4111-8111-111111111111';

insert into public.identity_verification_requests (user_id, method)
values ('11111111-1111-4111-8111-111111111111', 'manual_document_review');

do $test$
declare
  own_count integer;
  other_count integer;
  invalid_state_count integer;
begin
  select count(*) into own_count
    from public.identity_verification_requests
    where user_id = '11111111-1111-4111-8111-111111111111';

  select count(*) into other_count
    from public.identity_verification_requests
    where user_id = '22222222-2222-4222-8222-222222222222';

  select count(*) into invalid_state_count
    from public.identity_verification_requests
    where user_id = '11111111-1111-4111-8111-111111111111'
      and (status <> 'pending_review' or assurance_level <> 'none');

  if own_count <> 1 then
    raise exception 'RLS test failed: expected exactly one own request, found %', own_count;
  end if;
  if other_count <> 0 then
    raise exception 'RLS test failed: user can see another account''s request';
  end if;
  if invalid_state_count <> 0 then
    raise exception 'RLS test failed: new client request is not pending/unverified';
  end if;
end
$test$;

reset role;
