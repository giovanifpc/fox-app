-- ═══════════════════════════════════════════════════════
-- FOX PERFORMANCE — Vincular auth.user ao perfil manualmente
-- Rodar no SQL Editor do Supabase
-- ═══════════════════════════════════════════════════════

-- Vincular o UUID do auth ao perfil do cliente
update public.clients
set id = (
  select id from auth.users
  where email = 'giovani.work@hotmail.com'
  limit 1
)
where email = 'giovani.work@hotmail.com'
and id is null;

-- Verificar resultado
select email, id, nome from public.clients
where email = 'giovani.work@hotmail.com';

