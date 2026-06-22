drop policy if exists "client_context_select_own_or_admin" on public.client_context;
create policy "client_context_select_own_or_admin"
  on public.client_context
  for select
  using (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_context_insert_own_or_admin" on public.client_context;
create policy "client_context_insert_own_or_admin"
  on public.client_context
  for insert
  with check (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_context_update_own_or_admin" on public.client_context;
create policy "client_context_update_own_or_admin"
  on public.client_context
  for update
  using (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  )
  with check (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_context_delete_admin" on public.client_context;
create policy "client_context_delete_admin"
  on public.client_context
  for delete
  using (lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com');

drop policy if exists "client_weekly_notes_select_own_or_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_select_own_or_admin"
  on public.client_weekly_notes
  for select
  using (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_weekly_notes_insert_own_or_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_insert_own_or_admin"
  on public.client_weekly_notes
  for insert
  with check (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_weekly_notes_update_own_or_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_update_own_or_admin"
  on public.client_weekly_notes
  for update
  using (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  )
  with check (
    lower(client_email) = lower(coalesce(auth.email(), auth.jwt() ->> 'email'))
    or lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_weekly_notes_delete_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_delete_admin"
  on public.client_weekly_notes
  for delete
  using (lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com');
