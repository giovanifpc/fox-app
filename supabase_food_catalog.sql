create table if not exists public.food_catalog (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  portion numeric not null default 100,
  unit text not null default 'g',
  kcal numeric not null default 0,
  prot numeric not null default 0,
  carb numeric not null default 0,
  fat numeric not null default 0,
  cat text not null default 'outros',
  source text,
  barcode text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.food_catalog add column if not exists portion numeric not null default 100;
alter table public.food_catalog add column if not exists unit text not null default 'g';
alter table public.food_catalog add column if not exists kcal numeric not null default 0;
alter table public.food_catalog add column if not exists prot numeric not null default 0;
alter table public.food_catalog add column if not exists carb numeric not null default 0;
alter table public.food_catalog add column if not exists fat numeric not null default 0;
alter table public.food_catalog add column if not exists cat text not null default 'outros';
alter table public.food_catalog add column if not exists source text;
alter table public.food_catalog add column if not exists barcode text;
alter table public.food_catalog add column if not exists created_at timestamptz not null default now();
alter table public.food_catalog add column if not exists updated_at timestamptz not null default now();

create index if not exists food_catalog_name_lower_idx
  on public.food_catalog (lower(name));

create index if not exists food_catalog_cat_idx
  on public.food_catalog (cat);

grant select on public.food_catalog to authenticated;
grant insert, update, delete on public.food_catalog to authenticated;
grant select, insert, update, delete on public.food_catalog to service_role;

alter table public.food_catalog enable row level security;

drop policy if exists "food_catalog_select_authenticated" on public.food_catalog;
create policy "food_catalog_select_authenticated"
  on public.food_catalog
  for select
  using (auth.uid() is not null);

drop policy if exists "food_catalog_insert_admin" on public.food_catalog;
create policy "food_catalog_insert_admin"
  on public.food_catalog
  for insert
  with check (lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com');

drop policy if exists "food_catalog_update_admin" on public.food_catalog;
create policy "food_catalog_update_admin"
  on public.food_catalog
  for update
  using (lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com')
  with check (lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com');

drop policy if exists "food_catalog_delete_admin" on public.food_catalog;
create policy "food_catalog_delete_admin"
  on public.food_catalog
  for delete
  using (lower(coalesce(auth.email(), auth.jwt() ->> 'email')) = 'giovani.work@hotmail.com');
