# Novo App SaaS Fitness — Planejamento Completo

## Visão Geral

Aplicativo PWA mobile-first SaaS para personal trainers (e parceiros nutricionistas) gerenciarem seus alunos. O produto é vendido como assinatura mensal para o profissional, que usa a ferramenta com seus clientes.

**Modelo de negócio:** B2B2C
- **Giovani (master admin):** vende assinatura para profissionais, gerencia a plataforma
- **Profissional (tenant):** assina mensalmente, cadastra e gerencia seus alunos
- **Aluno (usuário final):** baixa e usa o app gratuitamente via convite do profissional

---

## Banner Comercial — O Que o Produto Promete

O banner mostra 5 módulos disponíveis para o aluno:

| Módulo | Descrição |
|---|---|
| **Treinos** | Protocolo de treino com GIFs dos exercícios, execução guiada |
| **Alimentação** | PDF do plano alimentar + orientações do nutricionista + receitas |
| **Evolução** | Registro de peso, medidas corporais e fotos com gráficos |
| **Arquivos** | Documentos enviados pelo profissional (PDFs, materiais, exames) |
| **Contato** | Canal direto com o profissional (WhatsApp, Instagram, email, avaliações) |

**Proposta de valor para o profissional:**
- Menos tempo perdido com mensagens repetitivas
- Aluno mais organizado, engajado e independente
- Acompanhamento com dados reais
- Marca mais forte e posicionada
- Maior taxa de permanência dos alunos

---

## Stack Técnica

Mesma base do Fox Performance (já construído e funcionando):

- **Frontend:** HTML + CSS + JS puro (sem framework)
- **Backend/Banco:** Supabase (Auth + PostgreSQL + Storage)
- **Hosting:** GitHub Pages (deploy automático via Actions)
- **Emails:** Resend
- **Pagamento:** Mercado Pago (assinatura recorrente)
- **PWA:** Service Worker com cache offline
- **Autenticação:** OTP por email (6-8 dígitos, mesmo fluxo do Fox)

**Reaproveitamento do Fox:** ~60% do código (design system, auth, training engine com GIFs, PWA/SW, componentes de UI, utilitários JS).

---

## Estrutura de Usuários (3 Camadas)

```
Giovani (Master Admin)
  └── Profissional A — assina R$X/mês
        ├── Aluno 1
        ├── Aluno 2
        └── Aluno N
  └── Profissional B — assina R$X/mês
        └── ...
```

### Autenticação — Destino por Perfil

```
Login OTP → após verificar:
  ├── email = admin master? → painel master
  ├── email em professionals (ativo)? → painel do profissional
  ├── email em students (ativo)? → app do aluno
  └── nenhum? → "Acesso não autorizado"
```

---

## Módulos por Tipo de Usuário

### Painel do Profissional

- **Dashboard:** alunos ativos, quem treinou hoje, últimos acessos, alunos sem atividade recente
- **Alunos:** cadastrar, ativar, pausar, desativar, ver perfil completo
- **Treinos:** montar protocolos com exercícios + GIFs, publicar para aluno específico ou todos
- **Arquivos:** adicionar PDFs/links por categoria (dietas, receitas, materiais, exames, outros), atribuir para aluno(s)
- **Evolução:** ver gráfico de peso e medidas de cada aluno, adicionar registros manualmente
- **Comunicação:** enviar notificações para aluno(s), link rápido para WhatsApp de cada aluno
- **Minha Assinatura:** status do plano, data de renovação, histórico de faturas, upgrade/downgrade

### App do Aluno (PWA)

- **Hub (início):** treino do dia, último peso registrado, notificações não lidas
- **Treinos:** protocolo atual com GIFs, execução guiada, marcar como concluído, histórico
- **Alimentação:** PDF do plano em destaque, orientações do nutricionista, receitas
- **Arquivos:** todos os documentos do profissional organizados por categoria
- **Evolução:** registrar peso/medidas/fotos, gráfico de progresso ao longo do tempo
- **Contato:** WhatsApp, Instagram, email, outros canais do profissional

### Painel Master (Giovani)

- **Dashboard:** profissionais ativos/suspensos/trial, MRR, total de alunos na plataforma
- **Profissionais:** ver todos, ativar/suspender manualmente, ver dados e alunos de qualquer profissional (suporte)
- **Financeiro:** log completo de pagamentos, assinaturas por vencer
- **Comunicados:** enviar notificação global para todos os profissionais (nova feature, manutenção)

---

## Modelo de Pagamento

### Camada 1 — Profissional → Giovani (assinatura mensal)

**Ferramenta:** Mercado Pago Assinaturas (melhor para Brasil — PIX recorrente, boleto, cartão)

**Fluxo:**
1. Profissional acessa landing page → escolhe plano → checkout Mercado Pago
2. Paga → MP dispara webhook → Edge Function ativa `subscription_status = active`
3. Profissional recebe email com acesso
4. Renovação mensal automática: webhook confirma → status mantido
5. Falha no pagamento: grace period de 3 dias → depois suspende acesso automaticamente

**Planos sugeridos (a definir comercialmente):**

| Plano | Limite de Alunos | Preço/mês |
|---|---|---|
| Starter | até 15 | R$ 79 |
| Pro | até 40 | R$ 149 |
| Elite | ilimitado | R$ 249 |

*(Valores são sugestão de ponto de partida — ajustar conforme pesquisa de mercado)*

### Camada 2 — Aluno → Profissional (fora do app no MVP)

No MVP, o profissional gerencia o pagamento dos alunos por conta própria (PIX, link de pagamento, Hotmart, etc.). No app, ele simplesmente ativa/desativa o aluno manualmente. Isso elimina toda a complexidade de marketplace e split de pagamento.

**V2 futuro:** campo "link de pagamento" nas configurações do profissional, exibido para o aluno dentro do app.

---

## Infraestrutura e Custos

### Supabase

- **Conta:** mesma conta do Fox — free tier permite 2 projetos ativos
- **Novo projeto separado:** banco isolado, RLS próprio, sem misturar com Fox
- **Limites do free tier:**
  - Banco: 500MB (suficiente para fase inicial com ~50 profissionais e seus alunos)
  - Storage (arquivos): 1GB
  - Bandwidth: 5GB/mês
  - Auth: 50.000 MAUs

### Estratégia de Storage para PDFs — 3 Fases

**Fase 1 — MVP (custo zero):** Links externos
- Profissional sobe PDF no próprio Google Drive/Dropbox e cola o link no app
- Supabase armazena apenas metadados (título, categoria, URL, destinatários)
- Consumo de storage no Supabase: **zero**
- Funciona perfeitamente para MVP

**Fase 2 — Crescimento (3+ profissionais pagando):** Supabase Pro
- $25/mês (~R$130) — inclui 100GB de storage e 8GB de banco
- Habilita upload nativo no app com controle de acesso por RLS
- Break-even: 2 profissionais pagando R$79/mês já cobre o custo

**Fase 3 — Escala (20+ profissionais):** Cloudflare R2
- 10GB gratuitos + sem taxa de saída (egress zero)
- Mais complexo de implementar, ideal para escala

### Custo Total por Fase

| Fase | Profissionais | Receita/mês | Custo infra | Margem |
|---|---|---|---|---|
| MVP | 0–3 | R$ 0–237 | R$ 0 | — |
| Crescimento | 3–10 | R$ 237–1.490 | R$ 130 | ~91% |
| Escala | 10–30 | R$ 1.490–4.470 | R$ 130–260 | ~95% |

---

## Banco de Dados — Tabelas Principais

```
professionals       → cadastro do profissional + status da assinatura + branding
students            → alunos vinculados ao professional_id
training_protocols  → protocolos de treino (com professional_id)
training_history    → sessões de treino realizadas pelos alunos
files               → PDFs/links por categoria, com atribuição por aluno
evolution_records   → peso, medidas, fotos por data
notifications       → avisos do profissional para alunos (in-app)
subscription_events → log de pagamentos e eventos de assinatura
```

**Isolamento multi-tenant:** todas as tabelas têm `professional_id`. RLS no Supabase garante que cada profissional acessa apenas seus próprios dados e alunos.

---

## Notificações

**MVP — In-app:**
- Notificações armazenadas no banco
- Badge de contagem na navegação do aluno
- Exibidas na abertura do app

**V2 — Push notification real:**
- OneSignal (gratuito até 10.000 subscribers)
- Integra ao PWA com Service Worker

**Emails automáticos via Resend (free: 3.000/mês):**
- Boas-vindas ao aluno quando cadastrado pelo profissional
- "Novo treino publicado para você"
- "Novo arquivo disponível"
- Lembrete se o aluno não acessou em X dias

---

## O Que Este App NÃO Tem (Diferença do Fox)

- ❌ NutriTracker (log diário de refeições e macros)
- ❌ Devolutiva semanal por IA (Claude API)
- ❌ Catálogo de alimentos
- ❌ Check-in de sono
- ❌ Relatório semanal automático (cron)
- ❌ Motor de conteúdo para Instagram

O app é mais simples e focado. Sem IA no MVP.

---

## Cronograma de Desenvolvimento (MVP)

| Fase | Entregável | Estimativa |
|---|---|---|
| 1 | Novo repo, Supabase multi-tenant, auth 3 camadas | 3–4 dias |
| 2 | Painel do profissional — alunos + treinos | 4–5 dias |
| 3 | App do aluno — treinos + arquivos + alimentação | 4–5 dias |
| 4 | Evolução — registro + gráficos | 2–3 dias |
| 5 | Contato + notificações in-app | 1–2 dias |
| 6 | Integração Mercado Pago (assinatura) | 3–4 dias |
| 7 | Painel master (Giovani gerencia profissionais) | 2–3 dias |
| 8 | Testes, ajustes, deploy e domínio | 2–3 dias |
| **Total MVP** | | **~3–4 semanas** |

---

## Decisões Comerciais Ainda em Aberto

- [ ] Nome definitivo do produto (independente da marca Fox?)
- [ ] Domínio próprio (ex: `meupersonalapp.com.br`)
- [ ] Valores dos planos (pesquisa de mercado com personals)
- [ ] Período de trial gratuito (7 dias? 14 dias?)
- [ ] Limite de alunos por plano (os valores acima são sugestão)
- [ ] Suporte ao profissional: só WhatsApp? Chat no app? Email?
- [ ] Onboarding assistido ou self-service?
- [ ] O profissional pode customizar logo/cor no app dos alunos? (branding white-label lite)
- [ ] Parceria nutricionista: o nutricionista tem acesso próprio ao painel? Ou o personal gerencia tudo?
- [ ] Política de reembolso e cancelamento

---

## Diferenciais Competitivos a Explorar

- **Setup em minutos:** profissional cadastra aluno e já publica treino no mesmo dia
- **GIFs de exercício:** aluno nunca executa errado por falta de referência visual
- **Tudo num lugar:** treino + dieta (PDF) + evolução + contato, sem ficar no WhatsApp
- **Marca do profissional:** o app reforça a identidade do personal, não da plataforma
- **Preço acessível:** comparado a concorrentes como Treinaweb, Tecnofit, Mefit

---

## Referências de Mercado (Concorrentes)

| Produto | Foco | Preço aprox. |
|---|---|---|
| Treinaweb | Personal trainer | R$ 100–300/mês |
| Tecnofit | Academia/personal | R$ 200+/mês |
| Mefit | Personal trainer | R$ 80–200/mês |
| Personal Trainer Pro | Personal | R$ 50–150/mês |

**Oportunidade:** produtos mais simples, sem excesso de funcionalidades, com bom UX mobile e preço competitivo no Starter.

---

## Contexto Técnico Adicional

- **Fox Performance (app base):** PWA já em produção em https://giovanifpc.github.io/fox-app
- **Repositório Fox:** https://github.com/giovanifpc/fox-app
- **Backend Fox:** Supabase em `https://jxwodkpssivmcnbrsukm.supabase.co`
- **O novo app terá repositório e projeto Supabase próprios**, mas reutiliza o design system e componentes do Fox
- **Design system:** dark mode com paleta roxa/cyan/âmbar, fontes Barlow Condensed + Barlow
- **Deploy:** GitHub Pages com GitHub Actions (gratuito)
