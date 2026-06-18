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

O resultado entra em `weekly_reports` com `status = draft`.

## 3. Variaveis da funcao

No Supabase, a funcao precisa ter:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `WEEKLY_REPORT_SECRET` opcional, para proteger chamadas manuais
- `ANTHROPIC_API_KEY` opcional, para gerar a devolutiva com Claude
- `ANTHROPIC_MODEL` opcional, para escolher o modelo Claude usado

Se `ANTHROPIC_API_KEY` nao estiver configurada, a funcao continua gerando o relatorio normalmente e preenche um rascunho simples de fallback.

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

## 5. Proximo bloco

O Admin ja possui uma area de revisao dos rascunhos gerados:

- selecione o cliente
- abra `Relatorios semanais`
- clique em `Carregar relatorios`
- revise o rascunho e as notas
- use `Marcar pronto` quando a devolutiva estiver pronta para a proxima etapa

Depois disso entram Claude API, WhatsApp e publicacao no Drive.
