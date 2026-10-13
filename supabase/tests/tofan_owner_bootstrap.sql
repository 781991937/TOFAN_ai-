-- Run after all migrations against the disposable CI PostgreSQL database.
-- Only synthetic accounts and identity-verification metadata are used.

insert into auth.users (id) values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
  ('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb')
on conflict (id) do nothing;

-- Direct client access and RPC invocation must be denied.
set role authenticated;
do $block$
begin
  begin
    insert into public.tofan_owner_assignment (owner_user_id, assignment_method)
    values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'verified_bootstrap');
    raise exception 'FAIL: authenticated client inserted owner assignment';
  exception when insufficient_privilege then
    raise notice 'PASS: authenticated client cannot insert owner assignment';
  end;

  begin
    perform public.claim_initial_tofan_owner('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
    raise exception 'FAIL: authenticated client executed owner bootstrap RPC';
  exception when insufficient_privilege then
    raise notice 'PASS: authenticated client cannot execute owner bootstrap RPC';
  end;
end;
$block$;
reset role;

-- No identity review means no owner claim, and failed claims must not consume bootstrap.
do $block$
begin
  begin
    perform * from public.claim_initial_tofan_owner('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
    raise exception 'FAIL: unverified identity was assigned owner';
  exception when insufficient_privilege then
    raise notice 'PASS: unverified account cannot claim owner';
  end;
  if exists (select 1 from private.tofan_owner_bootstrap_state where consumed_at is not null) then
    raise exception 'FAIL: rejected claim consumed bootstrap';
  end if;
end;
$block$;

-- Simulate a trusted reviewer decision; client roles cannot perform this transition.
insert into public.identity_verification_requests
  (user_id, status, method, assurance_level, reviewer_actor_id, reviewed_at)
values
  ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'verified', 'manual_document_review',
   'document_reviewed', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', now());

select * from public.claim_initial_tofan_owner('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

do $block$
begin
  if not exists (
    select 1 from public.tofan_owner_assignment
    where singleton = true and owner_user_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
  ) then
    raise exception 'FAIL: verified account was not assigned owner';
  end if;

  begin
    perform * from public.claim_initial_tofan_owner('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');
    raise exception 'FAIL: second account also claimed owner';
  exception when unique_violation then
    raise notice 'PASS: second bootstrap claim rejected';
  end;

  if (select count(*) from public.tofan_owner_assignment) <> 1 then
    raise exception 'FAIL: expected exactly one owner assignment';
  end if;
end;
$block$;

-- Reset the fixture so subsequent migration checks (if any) start cleanly.
