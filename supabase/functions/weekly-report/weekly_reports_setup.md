# Relatorio semanal automatico

Este bloco cria a base do relatorio automatico semanal.

## 1. Criar tabela no Supabase

Abra uma nova aba no SQL Editor do Supabase e rode o arquivo:

`supabase_weekly_reports.sql`

Ele cria a tabela `weekly_reports`, onde cada semana consolidada fica salva como rascunho para revisao.

Depois rode tambem:

`supabase_client_context.sql`

Ele cria:

- `client_context`: memoria fixa/anamnese do cliente
- `client_weekly_notes`: nota semanal e instrucao do Giovani para a devolutiva

Se o projeto ja tinha relatorios publicados e voce quer gerar novas versoes sem sobrescrever a devolutiva atual do cliente, rode tambem:

`supabase_weekly_reports_versions_fix.sql`

Ele permite que uma devolutiva publicada continue visivel no app enquanto um novo rascunho da mesma semana fica em revisao.

## 2. Edge Function

A funcao esta em:

`../supabase/functions/weekly-report/index.ts`

Ela consolida:

- treinos salvos em `training_history`
- alimentacao e agua em `nutri_history`
- metas publicadas em `weekly_goals`
- contexto fixo em `client_context`
- nota semanal em `client_weekly_notes`
- dados principais do cliente em `clients`

O resultado entra em `weekly_reports` como uma nova linha com `status = draft`.

## 3. Variaveis da funcao

No Supabase, a funcao precisa ter:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `WEEKLY_REPORT_SECRET` opcional, para proteger chamadas manuais
- `ADMIN_EMAIL` opcional, por padrao `giovani.work@hotmail.com`
- `ANTHROPIC_API_KEY` opcional, para gerar a devolutiva com Claude
- `ANTHROPIC_MODEL` opcional, para escolher o modelo Claude usado

Se `ANTHROPIC_API_KEY` nao estiver configurada, a funcao continua gerando o relatorio normalmente e preenche um rascunho simples de fallback.
O admin mostra a origem do rascunho:

- `Claude API`: a devolutiva veio da Claude API.
- `fallback sem Claude API`: a chave ainda nao foi configurada.
- `fallback por resposta vazia`: a API respondeu sem texto util.
- `erro na Claude API`: houve erro na chamada e o app usou fallback.

O modelo padrao atual no codigo e `claude-sonnet-4-6`. Configure `ANTHROPIC_MODEL` somente se quiser forcar outro modelo.

O Admin tambem consegue chamar a funcao manualmente pelo botao `Gerar rascunho`, desde que a funcao esteja publicada no Supabase Functions e o usuario logado seja o Admin.

Para publicar a funcao, siga tambem:

`edge_function_deploy.md`

## 4. Teste manual esperado

Quando a funcao estiver publicada, chamar com:

```json
{
  "client_email": "email-do-cliente",
  "period_start": "2026-06-15",
  "period_end": "2026-06-21"
}
```

Depois confira a tabela `weekly_reports`.

Campos esperados:

- `training_summary`: resumo dos treinos
- `nutri_summary`: resumo de alimentos e agua
- `goals_snapshot`: metas da semana com realizado consolidado
- `ai_draft`: devolutiva gerada pela Claude ou fallback simples
- `status`: inicialmente `draft`
- `raw_data.ai_status`: origem tecnica do rascunho
- `raw_data.ai_model`: modelo usado ou `fallback`
- `raw_data.ai_error`: erro tecnico, quando houver

## 5. Proximo bloco

O Admin ja possui uma area de revisao dos rascunhos gerados:

- selecione o cliente
- abra `Relatorios semanais`
- opcionalmente clique em `Gerar rascunho` para criar um relatorio manual do periodo escolhido
- clique em `Atualizar lista`
- revise o rascunho e as notas
- use `Marcar pronto` quando a devolutiva estiver pronta para a proxima etapa

Depois disso entram a automacao WhatsApp e a evolucao do fluxo de ciclo.
