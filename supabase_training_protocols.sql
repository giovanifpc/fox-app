create table if not exists public.training_protocols (
  id uuid primary key default gen_random_uuid(),
  client_email text not null,
  ciclo integer not null default 1,
  versao integer not null default 1,
  titulo text,
  status text not null default 'rascunho' check (status in ('rascunho', 'publicado', 'arquivado')),
  protocol_json jsonb not null,
  data_inicio date,
  data_fim date,
  publicado_em timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists training_protocols_client_status_idx
  on public.training_protocols (client_email, status, publicado_em desc);

alter table public.training_protocols enable row level security;

drop policy if exists "training_protocols_select_own_or_admin" on public.training_protocols;
create policy "training_protocols_select_own_or_admin"
  on public.training_protocols
  for select
  using (
    auth.jwt() ->> 'email' = client_email
    or auth.jwt() ->> 'email' = 'giovani.work@hotmail.com'
  );

drop policy if exists "training_protocols_insert_admin" on public.training_protocols;
create policy "training_protocols_insert_admin"
  on public.training_protocols
  for insert
  with check (auth.jwt() ->> 'email' = 'giovani.work@hotmail.com');

drop policy if exists "training_protocols_update_admin" on public.training_protocols;
create policy "training_protocols_update_admin"
  on public.training_protocols
  for update
  using (auth.jwt() ->> 'email' = 'giovani.work@hotmail.com')
  with check (auth.jwt() ->> 'email' = 'giovani.work@hotmail.com');

drop policy if exists "training_protocols_delete_admin" on public.training_protocols;
create policy "training_protocols_delete_admin"
  on public.training_protocols
  for delete
  using (auth.jwt() ->> 'email' = 'giovani.work@hotmail.com');
