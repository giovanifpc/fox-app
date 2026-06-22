-- Permite gerar novos rascunhos para o mesmo cliente e periodo sem sobrescrever
-- uma devolutiva ja publicada.

drop index if exists public.weekly_reports_client_period_idx;

create index if not exists weekly_reports_client_period_idx
  on public.weekly_reports (client_email, period_start, period_end);

create index if not exists weekly_reports_client_published_idx
  on public.weekly_reports (client_email, published, published_at desc);
