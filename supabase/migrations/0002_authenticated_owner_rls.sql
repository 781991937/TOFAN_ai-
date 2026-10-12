-- Scope persisted student data to the authenticated Supabase identity.
-- Dart repositories use currentUser.id (the string form of auth.uid()).
-- No service-role access, cross-user access, or client-side role escalation is added.

-- Table privileges are intentionally limited to operations used by the repositories;
-- row-level policies below further restrict every operation to the current user.
grant select, insert, update, delete
  on public.student_learning_state to authenticated;
grant select, insert, delete
  on public.experience_memory to authenticated;
grant select, insert
  on public.audit_events to authenticated;

-- Student learning state: users may manage only their own row.
drop policy if exists student_learning_state_owner_all
  on public.student_learning_state;
create policy student_learning_state_owner_all
  on public.student_learning_state
  for all
  to authenticated
  using (student_id = (select auth.uid())::text)
  with check (student_id = (select auth.uid())::text);

-- Experience memory: append, read, and clear only the caller's own records.
drop policy if exists experience_memory_owner_select
  on public.experience_memory;
create policy experience_memory_owner_select
  on public.experience_memory
  for select
  to authenticated
  using (actor_id = (select auth.uid())::text);

drop policy if exists experience_memory_owner_insert
  on public.experience_memory;
create policy experience_memory_owner_insert
  on public.experience_memory
  for insert
  to authenticated
  with check (actor_id = (select auth.uid())::text);

drop policy if exists experience_memory_owner_delete
  on public.experience_memory;
create policy experience_memory_owner_delete
  on public.experience_memory
  for delete
  to authenticated
  using (actor_id = (select auth.uid())::text);

-- Audit events are append-only from the client: insert and read own events.
-- No UPDATE or DELETE policy is provided, preserving audit history.
drop policy if exists audit_events_owner_select
  on public.audit_events;
create policy audit_events_owner_select
  on public.audit_events
  for select
  to authenticated
  using (actor_id = (select auth.uid())::text);

drop policy if exists audit_events_owner_insert
  on public.audit_events;
create policy audit_events_owner_insert
  on public.audit_events
  for insert
  to authenticated
  with check (actor_id = (select auth.uid())::text);
