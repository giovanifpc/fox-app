# Fox Performance App - Status de Continuidade

Data deste handoff: 2026-06-19

Este documento serve para uma nova sessao de GPT/Codex entender o estado atual do projeto sem depender do historico completo do chat.

## Visao geral do projeto

O app Fox Performance e um web app hospedado no GitHub Pages, com login e tabelas no Supabase. A estrategia atual e usar:

- GitHub Pages para hospedar as paginas.
- Supabase para autenticacao, permissoes e dados estruturados.
- Google Drive para armazenamento de arquivos pesados/PDFs.
- Supabase Edge Function para consolidar relatorios semanais.

O app e gratuito para os clientes, mas privado por login. O admin e operado pelo Giovani.

## Estrutura principal

Pasta principal do app:

`App fox v3/`

Arquivos principais:

- `index.html`: hub inicial do app.
- `login.html`: login Supabase.
- `admin.html`: painel admin do Giovani.
- `minha-area.html`: dashboard/area pessoal do cliente.
- `training.html`: app de treino.
- `nutri.html`: app de nutricao.
- `fox-logo-sem-fundo.svg`: logo.
- `exercises.json`: biblioteca/lista de exercicios.

Edge Function:

- `supabase/functions/weekly-report/index.ts`

SQLs importantes:

- `App fox v3/supabase_client_context.sql`
- `App fox v3/supabase_client_context_rls_fix.sql`
- `App fox v3/supabase_training_protocols.sql`
- `App fox v3/supabase_training_history.sql`
- `App fox v3/supabase_nutri_history.sql`
- `App fox v3/supabase_weekly_reports.sql`
- `App fox v3/supabase_weekly_reports_versions_fix.sql`
- `App fox v3/supabase_weekly_report_permissions_fix.sql`

## Estado atual funcional

### Login e clientes

- Login via Supabase funcionando.
- Admin protegido pelo email do Giovani.
- Cadastro de novos clientes no admin funciona.
- O Giovani tambem e cliente de teste, usando o mesmo email em muitos testes. Isso foi considerado nas politicas RLS: admin pode operar outros clientes e o cliente pode ver os proprios dados.

### Metas semanais

- Admin publica metas semanais por cliente.
- Minha Area le metas do Supabase.
- Rings e barras da Minha Area usam dados reais.
- Cores atuais:
  - Treino: ambar.
  - Hidratacao: azul claro.
  - Nutri: verde.
  - Sono: roxo.

### Training

- Training carrega protocolo dinamico pelo Supabase quando publicado no admin.
- Se nao houver protocolo publicado, usa treino padrao.
- Admin permite colar/importar JSON de treino.
- Existe validador de GIFs no admin.
- Training salva historico no Supabase em `training_history`.
- Registra sessoes, sets feitos, exercicios feitos e se o treino ficou incompleto.
- Medalhas do treino aparecem na Minha Area.

### Nutri

- Nutri salva refeicoes/hidratacao no Supabase em `nutri_history`.
- Agua e alimentos atualizam a mesma linha do dia.
- Rings da Minha Area contabilizam nutri e hidratacao.

### Minha Area

- Novo layout visual foi implementado com estetica de ficha/pasta.
- O cliente aparece na "orelha" da ficha.
- Paper principal mostra metas da semana, rings, score e conquistas.
- Quadro de medalhas usa formato 2 linhas de 5 blocos, com primeiro bloco simbolico `FOX`.
- Espacamentos foram ajustados e aprovados pelo usuario.
- Barra preta/logo do PDF tambem foi testada e aprovada.

Observacao tecnica:

- Ainda existe um bloco antigo escondido dos rings dentro de `minha-area.html`, com IDs duplicados, mas visualmente ele nao aparece.
- A versao nova aparece antes no DOM, entao a pagina funciona.
- Tarefa futura recomendada: remover esse bloco antigo com calma para limpar o HTML.

### Relatorios semanais

- Tabela `weekly_reports` funciona.
- Admin gera rascunho semanal via Edge Function.
- Admin revisa o texto.
- Admin marca pronto.
- Admin publica no app.
- Minha Area mostra a ultima devolutiva publicada.
- Admin pode excluir rascunhos nao publicados.
- Rascunhos antigos podem ficar no historico.
- Botao antes chamado "Carregar relatorios" foi ajustado para comportamento de atualizar lista.

### PDF / Drive

- Admin gera visualizacao imprimivel do PDF.
- Giovani pode salvar PDF manualmente e subir no Drive.
- Admin tem campo para colar link do PDF do Drive.
- Minha Area distingue:
  - `Abrir texto` quando nao ha PDF externo.
  - `Abrir PDF` quando ha link salvo.
- O botao abre corretamente o PDF/link.
- Barra preta atras da logo no PDF foi testada e aprovada.

### WhatsApp

- Admin tem botoes manuais para avisar cliente no WhatsApp:
  - Novo treino publicado.
  - Devolutiva publicada.
- Ainda nao ha automacao completa de WhatsApp.

### Anamnese / contexto

O bloco 3 foi implementado e testado pelo usuario com sucesso.

Arquivos alterados nesse bloco:

- `App fox v3/minha-area.html`
- `App fox v3/admin.html`
- `supabase/functions/weekly-report/index.ts`

Mudancas feitas:

- Minha Area ganhou anamnese inicial completa.
- Aparece aviso de "Anamnese inicial pendente" no dashboard quando incompleta.
- Formulario do cliente agora coleta:
  - Objetivo principal.
  - Resultado esperado.
  - Rotina e limitacoes.
  - Dias disponiveis para treino.
  - Tempo por treino.
  - Historico de treino.
  - Dores/lesoes/cuidados.
  - Restricoes/preferencias alimentares.
  - Sono medio.
  - Estresse atual.
  - Observacoes de estilo de vida.
  - Motivacao.
  - Preferencia de comunicacao.
- Dados principais continuam nos campos legiveis de `client_context`.
- Detalhes completos vao no JSONB `client_context.anamnesis`.
- Admin ganhou campo somente leitura `Anamnese preenchida no app`, que resume o JSON.
- Edge Function `weekly-report` agora formata a anamnese detalhada e inclui no fallback draft.
- A futura chamada Claude API ja recebe o `context` completo, incluindo `anamnesis`.

Validacao feita localmente:

- Scripts de `minha-area.html`: OK.
- Scripts de `admin.html`: OK.
- `index.ts` nao foi validado localmente com Deno porque Deno nao esta instalado na maquina. O deploy do Supabase deve validar na pratica.

Status:

- Minha Area salva a anamnese.
- Supabase recebe `client_context.anamnesis`.
- Admin exibe "Anamnese preenchida no app".
- Rascunho semanal inclui a anamnese.

### Claude API / devolutiva com IA

Fase 4 foi iniciada.

Arquivos alterados neste bloco:

- `supabase/functions/weekly-report/index.ts`
- `App fox v3/admin.html`
- `App fox v3/edge_function_deploy.md`
- `App fox v3/weekly_reports_setup.md`
- `GPT_HANDOFF_STATUS.md`

Mudancas feitas:

- Edge Function agora usa Claude API quando `ANTHROPIC_API_KEY` estiver configurada.
- Modelo padrao atualizado para `claude-sonnet-4-6`.
- Se nao houver chave, continua usando fallback.
- Se a Claude API falhar ou responder vazio, a funcao usa fallback e salva o motivo tecnico.
- Cada relatorio agora salva origem do rascunho em:
  - `raw_data.ai_status`
  - `raw_data.ai_model`
  - `raw_data.ai_error`
  - tambem espelha em `report_data.ai_status`, `report_data.ai_model`, `report_data.ai_error`
- Admin agora mostra um bloco `Origem do rascunho`:
  - Claude API
  - fallback sem Claude API
  - fallback por resposta vazia
  - erro na Claude API
- `Copiar resumo` tambem inclui a origem tecnica do rascunho.
- Documentacao de deploy foi atualizada com `npx supabase secrets set`.

Ainda precisa fazer para concluir/testar a fase 4:

1. Subir no Git:
   - `supabase/functions/weekly-report/index.ts`
   - `App fox v3/admin.html`
   - `App fox v3/edge_function_deploy.md`
   - `App fox v3/weekly_reports_setup.md`
   - `GPT_HANDOFF_STATUS.md`

2. Configurar chave Claude API no Supabase:

```powershell
npx supabase secrets set ANTHROPIC_API_KEY=sua_chave_da_claude
```

Opcional:

```powershell
npx supabase secrets set ANTHROPIC_MODEL=claude-sonnet-4-6
```

3. Publicar a funcao:

```powershell
npx supabase functions deploy weekly-report
```

4. Testar no admin:
   - selecionar cliente
   - gerar rascunho
   - confirmar se aparece `Origem do rascunho: Claude API`
   - revisar texto
   - marcar pronto
   - publicar

## Supabase - tabelas esperadas

Tabelas ja usadas pelo app:

- `clients`
- `weekly_goals`
- `training_protocols`
- `training_history`
- `nutri_history`
- `weekly_reports`
- `client_context`
- `client_weekly_notes`
- `checkin_data`
- `goals_progress`

Sobre `client_context`:

- Chave primaria: `client_email`.
- Campos principais:
  - `primary_goal`
  - `limitations`
  - `routine_notes`
  - `injuries_pain`
  - `food_restrictions`
  - `preferences`
  - `motivation_notes`
  - `communication_style`
  - `attention_points`
  - `anamnesis jsonb`
  - `raw_notes`
  - `created_at`
  - `updated_at`

Uso atual:

- Cliente preenche anamnese pelo app.
- Admin ve/edita campos principais.
- `anamnesis` guarda detalhes estruturados.
- `communication_style` e considerado campo interno do admin. A preferencia de comunicacao do cliente fica em `anamnesis.communication_preference`.

## Fluxo atual de trabalho do Giovani

1. Cadastrar cliente no Admin.
2. Publicar metas semanais.
3. Publicar treino do ciclo via JSON.
4. Avisar cliente manualmente pelo WhatsApp.
5. Cliente usa Training, Nutri e Minha Area.
6. Cliente preenche anamnese no app.
7. Admin adiciona notas semanais com informacoes vindas de conversas.
8. Admin gera rascunho semanal.
9. Admin revisa/ajusta.
10. Admin publica no app.
11. Opcionalmente gera PDF, sobe no Drive e salva link no admin.
12. Cliente abre texto ou PDF pela Minha Area.

## Proximas etapas reais

### 1. Concluir teste da Claude API

Prioridade imediata.

- Configurar `ANTHROPIC_API_KEY`.
- Deploy da Edge Function.
- Gerar rascunho.
- Confirmar origem `Claude API` no admin.
- Validar qualidade da devolutiva gerada.

### 2. Limpeza tecnica da Minha Area

- Remover bloco antigo escondido dos rings em `minha-area.html`.
- Eliminar IDs duplicados:
  - `dash-week-range`
  - `dash-achievements`
  - `dash-ring1` etc.
- Fazer essa limpeza com cuidado, porque a pagina esta funcionando.

### 3. Melhorar prompt e criterio da IA

Depois do primeiro teste real com Claude API:

- Ajustar tom.
- Ajustar tamanho da devolutiva.
- Refinar criterios pessoais do Giovani.
- Decidir se vale criar campos extras no admin para "criterios fixos da IA".

### 4. Melhorar biblioteca de exercicios/GIFs

Problema atual:

- JSON do treino pode apontar exercicio para GIF errado.
- Validador ajuda, mas ainda exige revisao manual.

Proximas ideias:

- Criar selector no admin a partir de `exercises.json`.
- Permitir buscar exercicio/GIF.
- Reduzir necessidade de copiar nome do arquivo no Drive manualmente.

### 5. Fluxo formal de ciclos

Ainda falta definir/implementar melhor:

- Quando novo ciclo comeca.
- O que reseta:
  - Metricas semanais.
  - Medalhas do ciclo.
  - Progresso de treino.
  - Historico.
- Botao admin claro: "Iniciar novo ciclo".
- Publicar treino novo deve ou nao reiniciar conquistas? Precisa decisao de produto.

### 6. Automacao WhatsApp

Hoje existe aviso manual via botao.

Futuro:

- Avisar Giovani quando devolutiva estiver pronta.
- Talvez avisar cliente apos publicacao.
- Avaliar custo/complexidade de WhatsApp API antes de automatizar.

### 7. App de loja / PWA

Ainda e futuro.

Caminho recomendado:

1. Estabilizar web app.
2. Transformar em PWA instalavel.
3. Depois empacotar com Capacitor para Android/iOS.

Custos discutidos:

- Google Play: taxa unica de desenvolvedor.
- Apple Developer: assinatura anual.

## Cuidados importantes para proximas sessoes

- Usuario prefere blocos maiores e seguros, para evitar muitas idas e vindas.
- Sempre preservar integridade do app atual.
- Evitar mexer em fluxo que ja esta testado sem necessidade.
- Usuario testa no GitHub Pages, Android e Edge.
- Git nao esta disponivel no terminal do Codex; usuario sobe arquivos manualmente.
- Se alterar Edge Function, lembrar de orientar deploy com:

```powershell
npx supabase functions deploy weekly-report
```

- Nem toda alteracao exige SQL. Para a anamnese atual, nao foi criado SQL novo.
- Se houver erro de RLS, provavelmente precisa revisar politicas em SQL, mas nao assumir antes de ver a mensagem.

## Estado dos itens antigos da lista original

Concluido ou funcional:

- Painel Admin para metas.
- Dashboard com dados reais.
- Training salvando no Supabase.
- Nutri salvando no Supabase.
- Training dinamico via Supabase.
- Relatorio semanal manual via Edge Function.
- Revisao/publicacao no admin.
- PDF/link Drive na Minha Area.
- Anamnese inicial: implementada e testada.
- Devolutiva com Claude API: implementada no codigo, pendente de configurar chave/deploy/teste real.

Ainda pendente:

- Notificacao WhatsApp automatica.
- Fluxo formal de ciclos.
- Biblioteca/admin melhor para exercicios e GIFs.
- Limpeza tecnica de HTML antigo na Minha Area.
- Empacotamento futuro como app de loja.
