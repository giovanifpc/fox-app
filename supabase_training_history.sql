create table if not exists public.training_history (
  id uuid primary key default gen_random_uuid(),
  client_email text not null,
  session_uid text not null,
  completed_at timestamptz not null,
  workout_id text,
  workout_name text,
  ciclo integer,
  semana integer,
  minutes integer,
  sets_done integer,
  exercises_done integer,
  incomplete boolean not null default false,
  protocol_title text,
  protocol_version integer,
  detail jsonb not null default '[]'::jsonb,
  raw_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.training_history add column if not exists session_uid text;
alter table public.training_history add column if not exists completed_at timestamptz;
alter table public.training_history add column if not exists workout_id text;
alter table public.training_history add column if not exists workout_name text;
alter table public.training_history add column if not exists ciclo integer;
alter table public.training_history add column if not exists semana integer;
alter table public.training_history add column if not exists minutes integer;
alter table public.training_history add column if not exists sets_done integer;
alter table public.training_history add column if not exists exercises_done integer;
alter table public.training_history add column if not exists incomplete boolean not null default false;
alter table public.training_history add column if not exists protocol_title text;
alter table public.training_history add column if not exists protocol_version integer;
alter table public.training_history add column if not exists detail jsonb not null default '[]'::jsonb;
alter table public.training_history add column if not exists raw_data jsonb not null default '{}'::jsonb;
alter table public.training_history add column if not exists created_at timestamptz not null default now();
alter table public.training_history add column if not exists updated_at timestamptz not null default now();

update public.training_history
set session_uid = coalesce(session_uid, gen_random_uuid()::text),
    completed_at = coalesce(completed_at, created_at, now())
where session_uid is null
   or completed_at is null;

alter table public.training_history alter column session_uid set not null;
alter table public.training_history alter column completed_at set not null;

create unique index if not exists training_history_client_session_uid_idx
  on public.training_history (client_email, session_uid);

create index if not exists training_history_client_completed_idx
  on public.training_history (client_email, completed_at desc);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.training_history to authenticated;

alter table public.training_history enable row level security;

drop policy if exists "training_history_select_own_or_admin" on public.training_history;
create policy "training_history_select_own_or_admin"
  on public.training_history
  for select
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "training_history_insert_own_or_admin" on public.training_history;
create policy "training_history_insert_own_or_admin"
  on public.training_history
  for insert
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "training_history_update_own_or_admin" on public.training_history;
create policy "training_history_update_own_or_admin"
  on public.training_history
  for update
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  )
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "training_history_delete_admin" on public.training_history;
create policy "training_history_delete_admin"
  on public.training_history
  for delete
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');
