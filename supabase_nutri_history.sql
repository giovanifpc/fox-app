create table if not exists public.nutri_history (
  id uuid primary key default gen_random_uuid(),
  client_email text not null,
  date_key text not null,
  logged_at timestamptz not null default now(),
  kcal numeric not null default 0,
  protein_g numeric not null default 0,
  carbs_g numeric not null default 0,
  fat_g numeric not null default 0,
  water_ml integer not null default 0,
  meals jsonb not null default '{}'::jsonb,
  profile jsonb not null default '{}'::jsonb,
  raw_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.nutri_history add column if not exists date_key text;
alter table public.nutri_history add column if not exists logged_at timestamptz not null default now();
alter table public.nutri_history add column if not exists kcal numeric not null default 0;
alter table public.nutri_history add column if not exists protein_g numeric not null default 0;
alter table public.nutri_history add column if not exists carbs_g numeric not null default 0;
alter table public.nutri_history add column if not exists fat_g numeric not null default 0;
alter table public.nutri_history add column if not exists water_ml integer not null default 0;
alter table public.nutri_history add column if not exists meals jsonb not null default '{}'::jsonb;
alter table public.nutri_history add column if not exists profile jsonb not null default '{}'::jsonb;
alter table public.nutri_history add column if not exists raw_data jsonb not null default '{}'::jsonb;
alter table public.nutri_history add column if not exists created_at timestamptz not null default now();
alter table public.nutri_history add column if not exists updated_at timestamptz not null default now();

update public.nutri_history
set date_key = coalesce(date_key, to_char(coalesce(logged_at, created_at, now()), 'YYYY-MM-DD'))
where date_key is null;

alter table public.nutri_history alter column date_key set not null;

delete from public.nutri_history a
using public.nutri_history b
where a.ctid < b.ctid
  and lower(a.client_email) = lower(b.client_email)
  and a.date_key = b.date_key;

create unique index if not exists nutri_history_client_date_key_idx
  on public.nutri_history (client_email, date_key);

create index if not exists nutri_history_client_logged_idx
  on public.nutri_history (client_email, logged_at desc);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.nutri_history to authenticated;

alter table public.nutri_history enable row level security;

drop policy if exists "nutri_history_select_own_or_admin" on public.nutri_history;
create policy "nutri_history_select_own_or_admin"
  on public.nutri_history
  for select
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "nutri_history_insert_own_or_admin" on public.nutri_history;
create policy "nutri_history_insert_own_or_admin"
  on public.nutri_history
  for insert
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "nutri_history_update_own_or_admin" on public.nutri_history;
create policy "nutri_history_update_own_or_admin"
  on public.nutri_history
  for update
  using (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  )
  with check (
    lower(client_email) = lower(auth.jwt() ->> 'email')
    or lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
  );

drop policy if exists "nutri_history_delete_admin" on public.nutri_history;
create policy "nutri_history_delete_admin"
  on public.nutri_history
  for delete
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');
