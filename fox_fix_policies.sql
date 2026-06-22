-- ═══════════════════════════════════════════════════════
-- FOX PERFORMANCE — Fix policies RLS
-- Problema: comparação de email via JWT falhando
-- Solução: usar auth.uid() + email direto
-- ═══════════════════════════════════════════════════════

-- ── Recriar policies da tabela clients ───────────────────
drop policy if exists "cliente lê próprio perfil" on public.clients;
drop policy if exists "cliente edita próprio perfil" on public.clients;
drop policy if exists "admin acesso total clients" on public.clients;

-- Permitir leitura por qualquer usuário autenticado que tenha o email
-- (necessário para o app funcionar antes do id ser preenchido pelo trigger)
create policy "cliente lê próprio perfil"
  on public.clients for select
  to authenticated
  using (
    auth.uid() = id
    or lower(email) = lower(auth.jwt() ->> 'email')
  );

create policy "cliente edita próprio perfil"
  on public.clients for update
  to authenticated
  using (
    auth.uid() = id
    or lower(email) = lower(auth.jwt() ->> 'email')
  );

create policy "admin acesso total clients"
  on public.clients for all
  to authenticated
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

-- ── Recriar policies das outras tabelas usando email ─────
-- weekly_goals
drop policy if exists "cliente lê próprias metas" on public.weekly_goals;
drop policy if exists "admin acesso total goals" on public.weekly_goals;

create policy "cliente lê próprias metas"
  on public.weekly_goals for select
  to authenticated
  using (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "admin acesso total goals"
  on public.weekly_goals for all
  to authenticated
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

-- training_history
drop policy if exists "cliente lê próprio treino" on public.training_history;
drop policy if exists "cliente insere treino" on public.training_history;
drop policy if exists "admin acesso total training" on public.training_history;

create policy "cliente lê próprio treino"
  on public.training_history for select
  to authenticated
  using (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "cliente insere treino"
  on public.training_history for insert
  to authenticated
  with check (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "admin acesso total training"
  on public.training_history for all
  to authenticated
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

-- nutri_history
drop policy if exists "cliente lê própria nutri" on public.nutri_history;
drop policy if exists "cliente insere nutri" on public.nutri_history;
drop policy if exists "admin acesso total nutri" on public.nutri_history;

create policy "cliente lê própria nutri"
  on public.nutri_history for select
  to authenticated
  using (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "cliente insere nutri"
  on public.nutri_history for insert
  to authenticated
  with check (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "admin acesso total nutri"
  on public.nutri_history for all
  to authenticated
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

-- checkin_data
drop policy if exists "cliente lê próprio checkin" on public.checkin_data;
drop policy if exists "cliente insere checkin" on public.checkin_data;
drop policy if exists "admin acesso total checkin" on public.checkin_data;

create policy "cliente lê próprio checkin"
  on public.checkin_data for select
  to authenticated
  using (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "cliente insere checkin"
  on public.checkin_data for insert
  to authenticated
  with check (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "admin acesso total checkin"
  on public.checkin_data for all
  to authenticated
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

-- goals_progress
drop policy if exists "cliente lê próprio progresso" on public.goals_progress;
drop policy if exists "cliente insere progresso" on public.goals_progress;
drop policy if exists "admin acesso total progress" on public.goals_progress;

create policy "cliente lê próprio progresso"
  on public.goals_progress for select
  to authenticated
  using (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "cliente insere progresso"
  on public.goals_progress for insert
  to authenticated
  with check (lower(client_email) = lower(auth.jwt() ->> 'email'));

create policy "admin acesso total progress"
  on public.goals_progress for all
  to authenticated
  using (lower(auth.jwt() ->> 'email') = 'giovani.work@hotmail.com');

