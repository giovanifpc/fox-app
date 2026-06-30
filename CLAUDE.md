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
├── admin.html          # Painel admin exclusivo do Giovani (6 abas)
├── sw.js               # Service Worker (cache versionado, fox-v1.0.5)
├── site.webmanifest    # PWA manifest
├── exercises.json      # Biblioteca de exercícios para autocomplete
├── data/exercises.json # Exercícios estruturados
├── supabase/
│   └── functions/weekly-report/index.ts  # Edge Function (devolutivas + motor de conteúdo)
├── .github/workflows/weekly-report-cron.yml       # Cron: sábado 02h BRT
├── .github/workflows/deploy-edge-functions.yml   # Deploy automático da Edge Function
└── supabase_*.sql      # Scripts de schema do banco (referência)
```

---

## Design system — CSS

Todos os arquivos usam o mesmo conjunto de variáveis CSS no `:root`. Copie este bloco para qualquer novo produto:

```css
:root {
  --bg:#0a0a0a;
  --surface:#121318;
  --card:#171922;
  --line:#292c36;
  --text:#f3f4f6;
  --muted:#9ca3af;
  --faint:#656b78;
  --purple:#7B8FD4;
  --cyan:#4FC3F7;
  --amber:#FF8C42;
  --green:#52B788;
  --danger:#e05555;
  --font:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Arial,sans-serif;
}
```

**Fontes via Google Fonts:** `Barlow Condensed` (títulos/chips) + `Barlow` (corpo)

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700;900&family=Barlow:wght@400;500;600;700&display=swap" rel="stylesheet">
```

---

## Padrões de UI reutilizáveis

### Botões

```css
.btn { padding:10px 18px; border-radius:10px; font-weight:700; font-size:14px; cursor:pointer; border:none; }
.btn.primary { background:var(--purple); color:#fff; }
.btn.secondary { background:var(--card); color:var(--text); border:1px solid var(--line); }
.btn:disabled { opacity:.45; cursor:not-allowed; }
```

### Sistema de abas (tab-btn + tab-content)

```html
<div class="tab-wrap">
  <button class="tab-btn active" onclick="switchTab('a')">Aba A</button>
  <button class="tab-btn" onclick="switchTab('b')">Aba B</button>
</div>
<div id="tab-a" class="tab-content active">...</div>
<div id="tab-b" class="tab-content">...</div>
```

```css
.tab-wrap{display:flex;gap:6px;flex-wrap:wrap;padding:12px 14px 0;border-bottom:1px solid var(--line);}
.tab-btn{padding:7px 14px;border-radius:8px;font-size:13px;font-weight:700;border:none;cursor:pointer;background:transparent;color:var(--muted);}
.tab-btn.active{background:var(--purple);color:#fff;}
.tab-content{display:none;padding:14px;}
.tab-content.active{display:block;}
```

```javascript
const TAB_INDEX = { a: 0, b: 1 }; // mapa nome → índice
function switchTab(name) {
  document.querySelectorAll('.tab-content').forEach((t, i) => t.classList.toggle('active', i === TAB_INDEX[name]));
  document.querySelectorAll('.tab-btn').forEach((b, i) => b.classList.toggle('active', i === TAB_INDEX[name]));
}
```

### Card

```css
.card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:14px 16px;}
```

### Toast (notificação temporária)

```javascript
function toast(msg) {
  const t = document.createElement('div');
  t.className = 'toast';
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 3000);
}
```

```css
.toast{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);background:#23263a;color:#fff;padding:10px 18px;border-radius:10px;font-size:14px;z-index:9999;pointer-events:none;white-space:nowrap;}
```

### Overlay / modal fullscreen

```html
<div id="myOverlay" class="overlay hidden">
  <div class="overlay-header">
    <button onclick="closeOverlay()">‹ Voltar</button>
    <span>Título</span>
  </div>
  <div class="overlay-body">...</div>
</div>
```

```css
.overlay{position:fixed;inset:0;background:var(--bg);z-index:200;display:flex;flex-direction:column;overflow:hidden;}
.overlay.hidden{display:none;}
.overlay-header{display:flex;align-items:center;gap:12px;padding:14px 16px;border-bottom:1px solid var(--line);}
.overlay-body{flex:1;overflow-y:auto;padding:14px 16px;}
```

### Details/summary (seção expansível)

```html
<details class="flow-section" open>
  <summary>Título da seção<span class="flow-kicker">Descrição curta.</span></summary>
  <div class="flow-body">conteúdo</div>
</details>
```

```css
.flow-section{border:1px solid var(--line);border-radius:12px;margin-bottom:10px;overflow:hidden;}
.flow-section summary{padding:12px 14px;cursor:pointer;font-weight:700;font-size:14px;display:flex;align-items:center;gap:8px;list-style:none;}
.flow-kicker{font-size:11px;font-weight:400;color:var(--muted);}
.flow-body{padding:12px 14px;border-top:1px solid var(--line);}
```

### Client-bar (barra de contexto de cliente selecionado)

```html
<div class="client-bar">
  <div>
    <div class="client-bar-name" id="someClientName">Nenhum cliente selecionado</div>
    <div class="client-bar-hint">Selecione um cliente na aba Clientes.</div>
  </div>
  <button class="btn secondary" onclick="switchTab('clients')">Ir para Clientes</button>
</div>
<div id="someTabContent" class="hidden"><!-- conteúdo aparece só quando cliente selecionado --></div>
```

```css
.client-bar{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:10px 14px;background:var(--surface);border-bottom:1px solid var(--line);}
.client-bar-name{font-weight:700;font-size:15px;}
.client-bar-hint{font-size:12px;color:var(--muted);}
.hidden{display:none!important;}
```

### Campos de formulário

```css
.field{display:flex;flex-direction:column;gap:4px;margin-bottom:10px;}
.field label{font-size:12px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.6px;}
.field input,.field textarea,.field select{background:var(--surface);border:1px solid var(--line);border-radius:8px;padding:9px 11px;color:var(--text);font-size:14px;font-family:var(--font);}
.field input:focus,.field textarea:focus{outline:none;border-color:var(--purple);}
.row.two{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
```

---

## Utilitários JS (presentes em admin.html — copie para novos projetos)

```javascript
function $(id){ return document.getElementById(id); }

function toast(msg){ /* ver seção UI acima */ }

function todayISO(){
  return new Date().toISOString().slice(0, 10);
}

function addDaysISO(iso, days){
  const d = new Date(iso + 'T12:00:00Z');
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}

function norm(s){ // normaliza string para comparação (lowercase, sem acentos)
  return String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
}

function escapeHtml(s){
  return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function errorText(err){
  if (!err) return 'Erro desconhecido';
  if (typeof err === 'string') return err;
  return err.message || String(err);
}
```

---

## Como chamar a Edge Function (padrão `invokeWeeklyReport`)

A função `invokeWeeklyReport(body)` em `admin.html` é o padrão para chamar a Edge Function com autenticação. Para novos projetos, adapte com a URL e secret corretos:

```javascript
async function invokeWeeklyReport(body) {
  const { data: { session } } = await supa.auth.getSession();
  const token = session?.access_token || '';
  const res = await fetch(
    'https://jxwodkpssivmcnbrsukm.supabase.co/functions/v1/weekly-report',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'x-weekly-report-secret': WEEKLY_REPORT_SECRET, // variável no topo do script
      },
      body: JSON.stringify(body),
    }
  );
  if (!res.ok) {
    const txt = await res.text().catch(() => '');
    throw new Error(`Edge Function erro ${res.status}: ${txt.slice(0, 200)}`);
  }
  return res.json();
}
```

---

## Edge Function — como estender

**Arquivo:** `supabase/functions/weekly-report/index.ts`

Cada nova funcionalidade é um novo `action` no bloco `serve()`. Padrão:

```typescript
// No bloco serve(), antes do catch final:
if (body.action === "minha_acao") {
  const result = await handleMinhaAcao({
    param1: String(body.param1 || ""),
  }, supa);
  return new Response(JSON.stringify(result), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Função separada (antes de serve()):
async function handleMinhaAcao(input: { param1: string }, supaClient) {
  // lógica aqui
  return { ok: true, data: {} };
}
```

**Actions existentes:**
- (sem action / cron): gera devolutivas em batch para todos os clientes
- `"rewrite"`: reescreve devolutiva com ajustes do Giovani
- `"generate_content"`: Motor de Conteúdo — gera post para Instagram a partir dos dados do cliente

**Deploy:** automático via GitHub Actions ao fazer push em `supabase/functions/**` para `main`. Não usar Supabase CLI nesta sessão (Docker ausente).

---

## Navegação entre módulos

O `index.html` abre os outros módulos via `openModule(which)` usando `<iframe class="module-frame">` em fullscreen — não é SPA com rotas. Os módulos (`training`, `nutri`, `drive`) são carregados como iframes sobre o hub.

**Iframes são reutilizados** (não destruídos ao fechar) — ao reabrir um módulo, `openModule()` envia `{type:'fox-module-activated'}` via `postMessage` para que o módulo resete seu estado interno (feche overlays, modais, telas secundárias).

**Botão voltar (`#fhb`)** em cada módulo chama uma função local antes de enviar `fox-back` ao Hub:
- `minha-area.html` → `handleAreaBack()`: fecha `reportOverlay` ou `historyOverlay` se ativos; senão vai ao Hub
- `training.html` → `handleBack()`: tela de execução → pede confirmação; outras telas → volta à home do treino; home → vai ao Hub
- `nutri.html` → `handleNutriBack()`: fecha modal aberto; se não estiver na aba "hoje" → vai pra "hoje"; senão vai ao Hub

**Comunicação Hub ↔ Módulos via `postMessage`:**
- Hub → Módulo: `{type:'fox-module-activated'}`, `{type:'fox-training-data'}`, `{type:'fox-nutri-data'}`, `{type:'fox-sleep-data'}`
- Módulo → Hub: `'fox-back'` (voltar ao hub), `{type:'fox-open-module', module}`

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

6 abas:

1. **Pendências** — fila de trabalho com cards vermelho/amarelo/verde por status de devolutiva, engajamento e fim de ciclo. "Check de quarta": ponto crítico da última devolutiva + mensagem WhatsApp pré-escrita por cliente
2. **Clientes** — cadastro de clientes, metas semanais, protocolo de treino
3. **Treinos** — formatter de protocolo (com botões de cardio: Caminhada, Esteira, Bike, Escada, Elíptico) → publicar protocolo para cliente
4. **Devolutivas** — visualiza/edita `ai_draft` → adiciona `coach_notes` → solicita reescrita pelo Claude → publica. Após publicar: opção de avançar semana automaticamente
5. **Contexto** — edita `client_context` (anamnese, objetivos, limitações, estilo de comunicação)
6. **Conteúdo** — Motor de Conteúdo: seleciona cliente + período + categoria → Claude gera post completo para Instagram (título, gancho, storytelling, slides, legenda, hashtags) sem identificar o cliente (FOX CASE #NNN)

---

## Geração automática de devolutivas

**Trigger:** GitHub Actions cron todo sábado às 02:00 BRT (05:00 UTC)

**Edge Function** (`supabase/functions/weekly-report/index.ts`):
1. Busca todos os clientes ativos
2. Para cada cliente (em batch, com isolamento de erro):
   - Coleta `training_history` + `nutri_history` + `weekly_goals` + `client_context` + `client_weekly_notes` da semana
   - Gera summaries de treino e nutrição
   - Chama **Claude API** (`claude-sonnet-4-6`, max_tokens 2000, temp 0.75) para escrever o `ai_draft`
   - Se falhar, usa `fallbackDraft` (texto estruturado sem IA)
   - Salva em `weekly_reports` (status: draft, published: false)
3. Envia email de log via **Resend** para `contatofoxperformance@gmail.com`

**Reescrita:** admin pode enviar `{action:"rewrite", report_id, coach_notes}` → Claude reescreve (max_tokens 2000, temp 0.70)

**Voz do prompt — regras atuais (geração e reescrita):**
- Texto em parágrafos corridos, estilo WhatsApp — sem bullets, listas, travessões (—), markdown
- Máximo 5 parágrafos curtos no total
- Permitido 1-2 emojis simples (🙂 💪) quando fizer sentido — não em todo parágrafo
- Proibido abrir com: "Espero que esteja bem", "Foi uma semana desafiadora", "Parabéns pela dedicação", "Olá"
- Palavras banidas: potencializar, alavancar, nortear, jornada, holística, evolução consistente, resultados expressivos
- Proibido usar a profissão do cliente para contextualizar recomendações
- Positivo deve ocupar mais espaço que o negativo; críticas mencionadas de passagem, nunca tom de cobrança
- Linguagem cotidiana: "proteína boa" em vez de "adesão proteica", "comeu menos" em vez de "déficit calórico"
- Fechamento convida resposta ou WhatsApp: "me chama no WhatsApp pra gente conversar sobre isso"
- Tom: direto, humano, íntimo — como Giovani fala com clientes que conhece há anos

**Deploy da Edge Function:**
- Feito via GitHub Actions (`.github/workflows/deploy-edge-functions.yml`)
- Trigger automático: push para `main` com mudanças em `supabase/functions/**`
- Trigger manual: `workflow_dispatch` no GitHub Actions
- Secrets necessários no repositório: `SUPABASE_ACCESS_TOKEN` e `SUPABASE_PROJECT_REF`
- **Não é possível fazer deploy direto desta sessão** (Docker ausente, proxy bloqueia `api.supabase.com`)

**Variáveis de ambiente da Edge Function:**
- `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
- `WEEKLY_REPORT_SECRET` (autenticação do cron)
- `ANTHROPIC_API_KEY`
- `ANTHROPIC_MODEL` (padrão: `claude-sonnet-4-6`)
- `RESEND_API_KEY`
- `LOG_EMAIL` (padrão: `contatofoxperformance@gmail.com`)
- `ADMIN_EMAIL` (padrão: `giovani.work@hotmail.com`)

---

## Motor de Conteúdo (implementado — aba "Conteúdo" do admin)

Gera posts completos para Instagram a partir dos dados reais do cliente, preservando anonimidade.

**FOX CASE:** número derivado client-side do array `clients` ordenado por `nome` alfabético, 1-based, zero-padded a 3 dígitos (`FOX CASE #001`). Sem coluna no banco — passado no payload.

**Categorias:** auto | consistencia | case | diario | licao | bastidores | comparativo

**Output gerado por Claude (JSON):**
- `fox_case`, `anonymous_profile`, `best_event`, `category`, `category_label`
- `titulo`, `gancho`, `storytelling` (2-4 parágrafos)
- `carousel_slides` (array de strings), `instagram_caption`, `hashtags`
- `image_suggestion`, `layout_template`, `cta`

**Privacidade:** nome do cliente nunca vai ao Claude. Apenas `client_email` é usado internamente na Edge Function para buscar os dados. O prompt recebe apenas: objetivo genérico, faixa etária, dados de treino/nutri anonimizados.

**Sem persistência:** geração efêmera — o usuário copia manualmente para o Instagram/CapCut.

---

## Service Worker

- Versão atual: `fox-v1.0.5` (bumpar a cada deploy que afete arquivos cacheados)
- Estratégia HTML: **network-first** com fallback para cache — cliente sempre recebe versão nova quando online
- Estratégia assets: **cache-first** com atualização em background
- **Network-only** (nunca cacheado): Supabase, googleapis, cdn.jsdelivr, `/admin`
- `admin.html` excluído do cache (sempre busca da rede)
- Para forçar atualização: bumpar a constante `VERSION` no `sw.js`
- `index.html` faz `setInterval(() => reg.update(), 3 * 60 * 1000)` para detectar novas versões do SW

**Shell cacheado:**
`index.html`, `login.html`, `training.html`, `nutri.html`, `minha-area.html`, `site.webmanifest`, ícones, `fox-logo-sem-fundo.svg`, `banner alongamento.png`, `exercises.json`

---

## Minha Área — estrutura atual

**Abas (ordem na nav):** Início · Feedback · Perfil · Docs · Fotos · Pag.

- **Início:** card de devolutiva com 3 botões (Ler / Baixar PDF / Anteriores), progresso, medidas rápidas
- **Feedback:** chips de energia (1–5) + textarea + envio via WhatsApp para o Giovani
- **Perfil:** anamnese + medidas corporais

**Anamnese** (`client_context.anamnesis` JSONB) — campos coletados:
- Objetivo, resultado esperado, rotina, dias/tempo de treino, histórico, lesões, alimentação, sono, estresse, estilo de vida, motivação, comunicação preferida
- `glp1_use` (boolean) e `glp1_dose` (string) — uso de análogo GLP-1 (Ozempic, Mounjaro, Wegovy, Saxenda)
- Quando `glp1_use = true`: Edge Function injeta instrução obrigatória no prompt ("meta calórica é referência, foco é proteína")

**Overlays de devolutiva:**
- `#reportOverlay` — leitura fullscreen com letterhead e botão de download PDF
- `#historyOverlay` — lista de todas as devolutivas publicadas
- Ambos fecham via `handleAreaBack()` ou ao receber `fox-module-activated`
- `allDevolutivas[]` armazena todas as devolutivas publicadas (fetch sem `.limit(1)`)
- `renderReportContent(text)` converte o texto da devolutiva para HTML, removendo markdown legado (`##`, `---`, `**bold**`, `*italic*`)

---

## Admin — estrutura atual

- **Header:** botão "‹ Hub" para voltar ao `index.html`
- **Abas:** 6 chips com `flex-wrap` — não transbordam no celular
- **Pendências:** cards por cliente; deduplica por `(client_email, period_start, period_end)` mantendo maior prioridade (verde > âmbar > vermelho); mensagem WhatsApp usa "Olá" e "aba Minha Área"
- **Devolutivas:** editar `ai_draft` → `coach_notes` → reescrever com Claude → publicar
  - Sem campo de link de Drive, sem botão "Marcar pronto", sem botão "Salvar PDF"

---

## Problemas já resolvidos (não regredir)

- **iOS PWA + login:** magic link quebrava sessão no iOS (localStorage isolado entre Safari e PWA). Solução: OTP de 6-8 dígitos — todo fluxo acontece dentro do PWA
- **Curly quotes no código:** aspas tipográficas (`"`) corrompiam `getElementById` em todos os elementos. Sempre usar aspas ASCII (`"`)
- **`admin.html` no cache:** causava versão desatualizada do painel. Está excluído do SW
- **OTP 8 dígitos:** Supabase envia código de 8 dígitos — campo aceita 6-8 (`maxlength="8"`)
- **Botão voltar ignorava estado interno:** `#fhb` mandava `fox-back` direto ao Hub mesmo com overlay aberto. Resolvido com `handleAreaBack()` / `handleBack()` / `handleNutriBack()` em cada módulo
- **Overlay persistia ao reabrir módulo:** iframes são reutilizados; `openModule()` agora envia `fox-module-activated` para que o módulo resete overlays/modais
- **Deploy da Edge Function impossível via CLI nesta sessão:** Docker ausente + proxy bloqueia `api.supabase.com`. Solução permanente: GitHub Actions (`deploy-edge-functions.yml`) faz deploy automático a cada push em `supabase/functions/**`
- **Busca de alimento no nutri travava >1 min:** `fetchOpenFoodSearch` sem timeout bloqueava tudo. Resolvido com `AbortSignal.timeout(5000)` + `searchFoodsSmart` rodando Open Food Facts e Supabase em paralelo via `Promise.all`
- **Cards verdes e vermelhos do mesmo cliente/período:** `loadPendencias()` não deduplicava. Resolvido com deduplicação por `(client_email, period_start, period_end)` mantendo maior prioridade
- **Campo GLP-1 na anamnese:** `glp1_use` e `glp1_dose` salvos em `client_context.anamnesis`; Edge Function injeta instrução no prompt quando `glp1_use=true` — tanto na geração quanto na reescrita

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
