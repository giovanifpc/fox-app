create table if not exists public.exercise_library (
  exercise_ref text primary key,
  name text not null,
  exercise_id integer,
  media_url text,
  media_type text not null default 'img',
  local_path text,
  source text not null default 'manual',
  notes text,
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.is_fox_admin()
returns boolean
language sql
stable
as $$
  select lower(coalesce(auth.email(), auth.jwt() ->> 'email', '')) in (
    'giovani.work@hotmail.com'
  );
$$;

alter table public.exercise_library enable row level security;

grant select, insert, update, delete on public.exercise_library to authenticated;

drop policy if exists "exercise_library_read_authenticated" on public.exercise_library;
create policy "exercise_library_read_authenticated"
on public.exercise_library
for select
to authenticated
using (true);

drop policy if exists "exercise_library_admin_insert" on public.exercise_library;
create policy "exercise_library_admin_insert"
on public.exercise_library
for insert
to authenticated
with check (public.is_fox_admin());

drop policy if exists "exercise_library_admin_update" on public.exercise_library;
create policy "exercise_library_admin_update"
on public.exercise_library
for update
to authenticated
using (public.is_fox_admin())
with check (public.is_fox_admin());

drop policy if exists "exercise_library_admin_delete" on public.exercise_library;
create policy "exercise_library_admin_delete"
on public.exercise_library
for delete
to authenticated
using (public.is_fox_admin());

drop trigger if exists exercise_library_touch_updated_at on public.exercise_library;
create trigger exercise_library_touch_updated_at
before update on public.exercise_library
for each row
execute function public.touch_updated_at();
