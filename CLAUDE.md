# Fox Performance — Contexto do Projeto

## O que é este app

PWA mobile-first de consultoria fitness para clientes da **Fox Performance** (Giovani). Permite que clientes acompanhem treinos, nutrição e recebam devolutivas semanais geradas por IA e revisadas pelo Giovani.

- **Produção:** https://giovanifpc.github.io/fox-app
- **Repositório:** https://github.com/giovanifpc/fox-app
- **Backend:** Supabase (`https://jxwodkpssivmcnbrsukm.supabase.co`)
- **Chave pública Supabase:** `sb_publishable_agSM3r3S7rb333VEmW2tiQ_Ng6GYV3K`
- **Stack:** HTML + CSS + JS puro (sem framework), Supabase Auth + DB, Claude API, Resend

---

## Regras de desenvolvimento

- **Branch principal:** `main` — todo commit vai direto para a main
- **GitHub Pages** serve a main automaticamente — mudanças ficam ao vivo após push
- **No PC (Windows):** edições via PowerShell + `git pull` para sincronizar após commits feitos aqui
- **Aqui (Claude Code web/celular):** faço edições, commit e push direto na main
- **Nunca usar `--no-verify` ou forçar push destrutivo sem confirmação explícita**
- Commits em português, mensagens descritivas

---

## Estrutura de arquivos

```
fox-app/
├── index.html          # Hub principal (dashboard, navegação, check-in sono)
├── login.html          # Autenticação OTP via Supabase
├── training.html       # Módulo de treino
├── nutri.html          # NutriTracker (refeições + água + macros)
├── minha-area.html     # Área do cliente (relatórios, documentos, evolução)
├── admin.html          # Painel admin exclusivo do Giovani
├── sw.js               # Service Worker (cache versionado, fox-v1.0.3)
├── site.webmanifest    # PWA manifest
├── exercises.json      # Biblioteca de exercícios para autocomplete
├── data/exercises.json # Exercícios estruturados
├── supabase/
│   └── functions/weekly-report/index.ts  # Edge Function de geração automática
├── .github/workflows/weekly-report-cron.yml  # Cron: sábado 02h BRT
└── supabase_*.sql      # Scripts de schema do banco (referência)
```

---

## Navegação entre módulos

O `index.html` abre os outros módulos via `openModule(which)` usando `<iframe class="module-frame">` em fullscreen — não é SPA com rotas. Os módulos (`training`, `nutri`, `drive`) são carregados como iframes sobre o hub.

---

## Autenticação

- **Fluxo:** OTP por e-mail (6-8 dígitos via Supabase `signInWithOtp`)
- **Gate:** função RPC `is_allowed_client(email)` — verifica se o email existe na tabela `clients`
- **Admin:** `giovani.work@hotmail.com` tem acesso total
- **Clientes:** acesso apenas aos próprios dados (RLS por email do JWT)
- **Motivo do OTP** (e não magic link): iOS isola o localStorage do PWA e do Safari — com magic link a sessão ficava no browser e o PWA pedia login toda vez

---

## Banco de dados — Tabelas principais

### `clients`
Cadastro master dos clientes.
- `email` (PK), `nome`, `ciclo_atual`, `semana_atual`, `total_semanas`, `folder_id`, `numero_whatsapp`

### `client_context`
Contexto fixo do cliente para personalizar devolutivas.
- `client_email` (PK), `primary_goal`, `limitations`, `injuries_pain`, `food_restrictions`, `preferences`, `routine_notes`, `motivation_notes`, `communication_style`, `attention_points`, `anamnesis` (JSONB), `raw_notes`

### `client_weekly_notes`
Nota do Giovani por ciclo/semana para cada cliente (usada na geração da devolutiva).
- `client_email`, `ciclo`, `semana`, `period_start`, `period_end`, `note`, `instruction`
- Unique: `(client_email, ciclo, semana)`

### `training_protocols`
Plano de treino publicado pelo Giovani.
- `client_email`, `ciclo`, `versao`, `titulo`, `status` (`rascunho/publicado/arquivado`), `protocol_json` (JSONB), `data_inicio`, `data_fim`, `publicado_em`
- Clientes só leem; apenas admin escreve

### `training_history`
Sessões de treino realizadas pelo cliente.
- `client_email`, `session_uid` (unique), `completed_at`, `workout_id`, `workout_name`, `ciclo`, `semana`, `minutes`, `sets_done`, `exercises_done`, `incomplete`, `protocol_title`, `protocol_version`, `detail` (JSONB), `raw_data` (JSONB)

### `nutri_history`
Log diário de nutrição (1 registro por dia por cliente).
- `client_email`, `date_key` (YYYY-MM-DD, unique com email), `kcal`, `protein_g`, `carbs_g`, `fat_g`, `water_ml`, `meals` (JSONB), `profile` (JSONB), `raw_data` (JSONB)

### `weekly_reports`
Devolutivas semanais geradas automaticamente + revisadas pelo Giovani.
- `client_email`, `ciclo`, `semana`, `period_start`, `period_end`, `status`, `training_summary` (JSONB), `nutri_summary` (JSONB), `sleep_summary` (JSONB), `goals_snapshot` (JSONB), `report_data` (JSONB), `ai_draft` (texto gerado pelo Claude), `coach_notes` (ajustes do Giovani), `published` (boolean), `published_at`
- Clientes só veem registros com `published = true`

### `weekly_goals`
Metas semanais publicadas pelo Giovani para cada cliente.
- `client_email`, `ciclo`, `semana`, `metas` (array JSONB), `foco_semana` (texto exibido no hub), `publicado` (boolean), `data_inicio`, `data_fim`

### `food_catalog`
Catálogo de alimentos com macros (leitura para todos autenticados, escrita só admin).
- `name`, `brand`, `portion`, `unit`, `kcal`, `prot`, `carb`, `fat`, `cat`, `barcode`, `serving_options` (JSONB), `verified`

---

## Fluxo do cliente (passo a passo)

1. `login.html` → digita email → recebe OTP → verifica → `index.html`
2. Hub mostra: progresso ciclo/semana, foco da semana, resumo (treinos, hidratação, sono, aderência)
3. Check-in matinal de sono (modal — qualidade + duração)
4. **Training:** carrega `training_protocols` (status=publicado) → executa treino → salva em `training_history`
5. **NutriTracker:** busca `food_catalog` → loga refeições → salva em `nutri_history`
6. **Minha Área:** vê `weekly_reports` publicados, documentos, evolução

---

## Fluxo admin (Giovani — admin.html)

4 abas:

1. **Pendências** — fila de trabalho com cards vermelho/amarelo/verde por status de devolutiva, engajamento e fim de ciclo. "Check de quarta": ponto crítico da última devolutiva + mensagem WhatsApp pré-escrita por cliente
2. **Clientes** — cadastro de clientes, metas semanais, protocolo de treino
3. **Devolutivas** — visualiza/edita `ai_draft` → adiciona `coach_notes` → solicita reescrita pelo Claude → publica. Após publicar: opção de avançar semana automaticamente
4. **Treinos** — formatter de protocolo (com botões de cardio: Caminhada, Esteira, Bike, Escada, Elíptico) → publicar protocolo para cliente

---

## Geração automática de devolutivas

**Trigger:** GitHub Actions cron todo sábado às 02:00 BRT (05:00 UTC)

**Edge Function** (`supabase/functions/weekly-report/index.ts`):
1. Busca todos os clientes ativos
2. Para cada cliente (em batch, com isolamento de erro):
   - Coleta `training_history` + `nutri_history` + `weekly_goals` + `client_context` + `client_weekly_notes` da semana
   - Gera summaries de treino e nutrição
   - Chama **Claude API** (`claude-sonnet-4-6`, max_tokens 3200, temp 0.4) para escrever o `ai_draft`
   - Se falhar, usa `fallbackDraft` (texto estruturado sem IA)
   - Salva em `weekly_reports` (status: draft, published: false)
3. Envia email de log via **Resend** para `contatofoxperformance@gmail.com`

**Reescrita:** admin pode enviar `{action:"rewrite", report_id, coach_notes}` → Claude reescreve respeitando os ajustes do Giovani (temp 0.35)

**Variáveis de ambiente da Edge Function:**
- `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
- `WEEKLY_REPORT_SECRET` (autenticação do cron)
- `ANTHROPIC_API_KEY`
- `ANTHROPIC_MODEL` (padrão: `claude-sonnet-4-6`)
- `RESEND_API_KEY`
- `LOG_EMAIL` (padrão: `contatofoxperformance@gmail.com`)
- `ADMIN_EMAIL` (padrão: `giovani.work@hotmail.com`)

---

## Service Worker

- Versão atual: `fox-v1.0.3` (bumpar a cada deploy que afete arquivos cacheados)
- Estratégia: **cache-first** para shell assets, **network-only** para Supabase, googleapis, cdn.jsdelivr e `/admin`
- `admin.html` excluído do cache (sempre busca da rede)
- Para forçar atualização: bumpar a constante `VERSION` no `sw.js`

**Shell cacheado:**
`index.html`, `login.html`, `training.html`, `nutri.html`, `minha-area.html`, `site.webmanifest`, ícones, `fox-logo-sem-fundo.svg`, `banner alongamento.png`, `exercises.json`

---

## Problemas já resolvidos (não regredir)

- **iOS PWA + login:** magic link quebrava sessão no iOS (localStorage isolado entre Safari e PWA). Solução: OTP de 6-8 dígitos — todo fluxo acontece dentro do PWA
- **Curly quotes no código:** aspas tipográficas (`"`) corrompiam `getElementById` em todos os elementos. Sempre usar aspas ASCII (`"`)
- **`admin.html` no cache:** causava versão desatualizada do painel. Está excluído do SW
- **OTP 8 dígitos:** Supabase envia código de 8 dígitos — campo aceita 6-8 (`maxlength="8"`)

---

## Convenções de código

- Sem frameworks — HTML/CSS/JS vanilla
- CSS em bloco `<style>` inline no próprio arquivo HTML (monolítico por página)
- JS no final do `<body>` no próprio arquivo
- Variáveis CSS com `--` no `:root`
- Fontes: `Barlow Condensed` (títulos) e `Barlow` (corpo) via Google Fonts
- Paleta principal: `--purple:#7B8FD4`, `--cyan:#4FC3F7`, `--amber:#FF8C42`, `--green:#52B788`, `--bg:#0a0a0a`
- Sem comentários desnecessários no código
- Sem TypeScript no frontend (só na Edge Function)
