-- Isolated database checks for WebAuthn metadata and owner step-up receipts.
-- No real credentials or biometric material are used.

set role authenticated;
do $block$
begin
  begin
    insert into public.tofan_passkey_credentials
      (credential_id, user_id, public_key_base64, device_type)
    values ('synthetic-credential', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
            'cHVibGljLWtleS1maXh0dXJl', 'singleDevice');
    raise exception 'FAIL: authenticated client inserted passkey credential';
  exception when insufficient_privilege then
    raise notice 'PASS: client cannot insert passkey credentials';
  end;

  begin
    insert into public.tofan_passkey_challenges (user_id, ceremony, challenge)
    values ('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'authentication', 'synthetic-challenge');
    raise exception 'FAIL: authenticated client inserted a WebAuthn challenge';
  exception when insufficient_privilege then
    raise notice 'PASS: client cannot forge WebAuthn challenges';
  end;

  begin
    perform public.consume_tofan_owner_step_up(
      'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', repeat('a', 64)
    );
    raise exception 'FAIL: authenticated client consumed a privileged step-up receipt';
  exception when insufficient_privilege then
    raise notice 'PASS: client cannot consume owner step-up receipts directly';
  end;
end;
$block$;
reset role;

-- Owner aaaa was assigned by the prior owner-bootstrap test.
insert into public.tofan_owner_step_up_grants
  (token_hash, user_id, scope, expires_at)
values
  (repeat('a', 64), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'owner_operation', now() + interval '1 minute'),
  (repeat('b', 64), 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'owner_operation', now() + interval '1 minute');

do $block$
declare
  first_result boolean;
  replay_result boolean;
  non_owner_result boolean;
begin
  select public.consume_tofan_owner_step_up(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', repeat('a', 64)
  ) into first_result;
  if first_result is distinct from true then
    raise exception 'FAIL: valid owner step-up receipt was not accepted';
  end if;

  select public.consume_tofan_owner_step_up(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', repeat('a', 64)
  ) into replay_result;
  if replay_result is distinct from false then
    raise exception 'FAIL: replayed step-up receipt was accepted';
  end if;

  select public.consume_tofan_owner_step_up(
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', repeat('b', 64)
  ) into non_owner_result;
  if non_owner_result is distinct from false then
    raise exception 'FAIL: non-owner consumed a privileged step-up receipt';
  end if;

  raise notice 'PASS: owner step-up receipt is one-time and owner-bound';
end;
$block$;
