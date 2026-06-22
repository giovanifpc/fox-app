create table if not exists public.weekly_reports (
  id uuid primary key default gen_random_uuid(),
  client_email text not null,
  ciclo integer,
  semana integer,
  period_start date not null,
  period_end date not null,
  status text not null default 'draft',
  generated_at timestamptz not null default now(),
  training_summary jsonb not null default '{}'::jsonb,
  nutri_summary jsonb not null default '{}'::jsonb,
  sleep_summary jsonb not null default '{}'::jsonb,
  checkin_summary jsonb not null default '{}'::jsonb,
  goals_snapshot jsonb not null default '[]'::jsonb,
  report_data jsonb not null default '{}'::jsonb,
  ai_draft text,
  coach_notes text,
  published boolean not null default false,
  published_at timestamptz,
  drive_file_id text,
  raw_data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.weekly_reports add column if not exists ciclo integer;
alter table public.weekly_reports add column if not exists semana integer;
alter table public.weekly_reports add column if not exists period_start date;
alter table public.weekly_reports add column if not exists period_end date;
alter table public.weekly_reports add column if not exists status text not null default 'draft';
alter table public.weekly_reports add column if not exists generated_at timestamptz not null default now();
alter table public.weekly_reports add column if not exists training_summary jsonb not null default '{}'::jsonb;
alter table public.weekly_reports add column if not exists nutri_summary jsonb not null default '{}'::jsonb;
alter table public.weekly_reports add column if not exists sleep_summary jsonb not null default '{}'::jsonb;
alter table public.weekly_reports add column if not exists checkin_summary jsonb not null default '{}'::jsonb;
alter table public.weekly_reports add column if not exists goals_snapshot jsonb not null default '[]'::jsonb;
alter table public.weekly_reports add column if not exists report_data jsonb not null default '{}'::jsonb;
alter table public.weekly_reports add column if not exists ai_draft text;
alter table public.weekly_reports add column if not exists coach_notes text;
alter table public.weekly_reports add column if not exists published boolean not null default false;
alter table public.weekly_reports add column if not exists published_at timestamptz;
alter table public.weekly_reports add column if not exists drive_file_id text;
alter table public.weekly_reports add column if not exists raw_data jsonb not null default '{}'::jsonb;
alter table public.weekly_reports add column if not exists created_at timestamptz not null default now();
alter table public.weekly_reports add column if not exists updated_at timestamptz not null default now();

update public.weekly_reports
set period_start = coalesce(period_start, generated_at::date),
    period_end = coalesce(period_end, generated_at::date)
where period_start is null
   or period_end is null;

alter table public.weekly_reports alter column period_start set not null;
alter table public.weekly_reports alter column period_end set not null;

create unique index if not exists weekly_reports_client_period_idx
  on public.weekly_reports (client_email, period_start, period_end);

create index if not exists weekly_reports_client_generated_idx
  on public.weekly_reports (client_email, generated_at desc);

create index if not exists weekly_reports_status_idx
  on public.weekly_reports (status, generated_at desc);

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.weekly_reports to authenticated;

alter table public.weekly_reports enable row level security;

drop policy if exists "weekly_reports_select_published_own_or_admin" on public.weekly_reports;
create policy "weekly_reports_select_published_own_or_admin"
  on public.weekly_reports
  for select
  using (
    lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com'
    or (
      lower(client_email) = lower(auth.jwt() ->> 'email')
      and published = true
    )
  );

drop policy if exists "weekly_reports_insert_admin" on public.weekly_reports;
create policy "weekly_reports_insert_admin"
  on public.weekly_reports
  for insert
  with check (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

drop policy if exists "weekly_reports_update_admin" on public.weekly_reports;
create policy "weekly_reports_update_admin"
  on public.weekly_reports
  for update
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com')
  with check (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

drop policy if exists "weekly_reports_delete_admin" on public.weekly_reports;
create policy "weekly_reports_delete_admin"
  on public.weekly_reports
  for delete
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');
