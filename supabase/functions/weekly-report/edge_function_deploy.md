# Publicar Edge Function weekly-report

O arquivo `supabase/functions/weekly-report/index.ts` estar no GitHub nao publica a funcao no Supabase.
Para o botao `Gerar rascunho` funcionar, a funcao precisa ser publicada no Supabase Functions.

## Caminho esperado no GitHub

```text
supabase/
  config.toml
  functions/
    weekly-report/
      index.ts
```

## Opcao recomendada: Supabase CLI

No computador, dentro da pasta principal do projeto:

```bash
npx supabase login
npx supabase link --project-ref jxwodkpssivmcnbrsukm
npx supabase functions deploy weekly-report
```

## Variaveis/secrets

A funcao usa:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `ADMIN_EMAIL`
- `ANTHROPIC_API_KEY`
- `ANTHROPIC_MODEL`
- `WEEKLY_REPORT_SECRET`

Normalmente o Supabase ja fornece `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` dentro das Edge Functions.

Para ativar a devolutiva com Claude API, configure pelo menos `ANTHROPIC_API_KEY`.
O modelo padrao do codigo e `claude-sonnet-4-6`; voce so precisa configurar `ANTHROPIC_MODEL` se quiser forcar outro modelo.

```bash
npx supabase secrets set ADMIN_EMAIL=giovani.work@hotmail.com
npx supabase secrets set ANTHROPIC_API_KEY=sua_chave_da_claude
npx supabase secrets set ANTHROPIC_MODEL=claude-sonnet-4-6
```

Depois de alterar secrets, rode novamente:

```bash
npx supabase functions deploy weekly-report
```

`WEEKLY_REPORT_SECRET` fica para a automacao/agendamento futuro. O botao do Admin usa o login do Giovani.

## Teste no app

1. Abra `admin.html`.
2. Selecione o cliente.
3. Salve o contexto.
4. Em `Relatorios semanais`, clique em `Gerar rascunho`.
5. Confira no painel se o bloco `Origem do rascunho` mostra `Claude API`.
6. Confira a tabela `weekly_reports`, se quiser auditar.

Resultado esperado:

- cria ou atualiza uma linha em `weekly_reports`
- preenche `training_summary`
- preenche `nutri_summary`
- preenche `goals_snapshot`
- preenche `ai_draft`

Se `ANTHROPIC_API_KEY` ainda nao estiver configurada, `ai_draft` vira um rascunho simples de fallback e o admin mostra `fallback sem Claude API`.
