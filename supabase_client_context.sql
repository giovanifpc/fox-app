create table if not exists public.client_context (
  client_email text primary key,
  primary_goal text,
  limitations text,
  injuries_pain text,
  food_restrictions text,
  preferences text,
  routine_notes text,
  motivation_notes text,
  communication_style text,
  attention_points text,
  anamnesis jsonb not null default '{}'::jsonb,
  raw_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.client_context add column if not exists primary_goal text;
alter table public.client_context add column if not exists limitations text;
alter table public.client_context add column if not exists injuries_pain text;
alter table public.client_context add column if not exists food_restrictions text;
alter table public.client_context add column if not exists preferences text;
alter table public.client_context add column if not exists routine_notes text;
alter table public.client_context add column if not exists motivation_notes text;
alter table public.client_context add column if not exists communication_style text;
alter table public.client_context add column if not exists attention_points text;
alter table public.client_context add column if not exists anamnesis jsonb not null default '{}'::jsonb;
alter table public.client_context add column if not exists raw_notes text;
alter table public.client_context add column if not exists created_at timestamptz not null default now();
alter table public.client_context add column if not exists updated_at timestamptz not null default now();

create table if not exists public.client_weekly_notes (
  id uuid primary key default gen_random_uuid(),
  client_email text not null,
  ciclo integer,
  semana integer,
  period_start date,
  period_end date,
  note text,
  instruction text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.client_weekly_notes add column if not exists ciclo integer;
alter table public.client_weekly_notes add column if not exists semana integer;
alter table public.client_weekly_notes add column if not exists period_start date;
alter table public.client_weekly_notes add column if not exists period_end date;
alter table public.client_weekly_notes add column if not exists note text;
alter table public.client_weekly_notes add column if not exists instruction text;
alter table public.client_weekly_notes add column if not exists created_at timestamptz not null default now();
alter table public.client_weekly_notes add column if not exists updated_at timestamptz not null default now();

create unique index if not exists client_weekly_notes_client_cycle_week_idx
  on public.client_weekly_notes (client_email, ciclo, semana);

create index if not exists client_weekly_notes_client_period_idx
  on public.client_weekly_notes (client_email, period_start, period_end);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.client_context to authenticated;
grant select, insert, update, delete on public.client_weekly_notes to authenticated;

alter table public.client_context enable row level security;
alter table public.client_weekly_notes enable row level security;

drop policy if exists "client_context_select_own_or_admin" on public.client_context;
create policy "client_context_select_own_or_admin"
  on public.client_context
  for select
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_context_insert_own_or_admin" on public.client_context;
create policy "client_context_insert_own_or_admin"
  on public.client_context
  for insert
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_context_update_own_or_admin" on public.client_context;
create policy "client_context_update_own_or_admin"
  on public.client_context
  for update
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  )
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_context_delete_admin" on public.client_context;
create policy "client_context_delete_admin"
  on public.client_context
  for delete
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

drop policy if exists "client_weekly_notes_select_own_or_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_select_own_or_admin"
  on public.client_weekly_notes
  for select
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_weekly_notes_insert_own_or_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_insert_own_or_admin"
  on public.client_weekly_notes
  for insert
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_weekly_notes_update_own_or_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_update_own_or_admin"
  on public.client_weekly_notes
  for update
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  )
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "client_weekly_notes_delete_admin" on public.client_weekly_notes;
create policy "client_weekly_notes_delete_admin"
  on public.client_weekly_notes
  for delete
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');
