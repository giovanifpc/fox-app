-- ═══════════════════════════════════════════════════════
-- FOX PERFORMANCE — Dados iniciais do Rafael
-- Rodar no SQL Editor do Supabase
-- ═══════════════════════════════════════════════════════

-- ── 1. Atualizar perfil do Rafael ────────────────────────
update public.clients set
  ciclo_atual     = 1,
  semana_atual    = 1,
  total_semanas   = 8,
  folder_id       = '1_9UFXRFe5D1ya5y-2nGVkP04BlHWIDYb',
  numero_whatsapp = '5511943503379'
where email = 'giovani.work@hotmail.com';

-- ── 2. Metas da semana 1 do ciclo 1 ─────────────────────
insert into public.weekly_goals
  (client_email, ciclo, semana, metas, foco_semana, data_inicio, data_fim, publicado)
values (
  'giovani.work@hotmail.com',
  1,
  1,
  '[
    {"nome": "Treinos",      "meta_valor": 3, "unidade": "sessões", "realizado": 0},
    {"nome": "Hidratação",   "meta_valor": 7, "unidade": "dias",    "realizado": 0},
    {"nome": "Diário Nutri", "meta_valor": 7, "unidade": "dias",    "realizado": 0},
    {"nome": "Sono 7h+",     "meta_valor": 7, "unidade": "dias",    "realizado": 0}
  ]',
  'Manter déficit calórico entre 300–400 kcal. Priorizar sono de qualidade — sono curto está limitando sua recuperação. Treino C obrigatório na quinta-feira.',
  '2026-06-09',
  '2026-06-15',
  true
)
on conflict (client_email, ciclo, semana) do update set
  metas       = excluded.metas,
  foco_semana = excluded.foco_semana,
  data_inicio = excluded.data_inicio,
  data_fim    = excluded.data_fim,
  publicado   = excluded.publicado;

