# O piso de fábrica — o que vem montado no dia 0

> "Projeto da casa" quer dizer **projeto que já nasce com o piso inteiro**. Este reference lista,
> peça por peça, o que o `/scaffold-new` monta antes de escrever a primeira feature — e o que o
> `/scaffold-check` procura num projeto existente. Nada aqui é "pra depois". A base normativa de
> cada item está nas references da `schematize-engineering`.

## 0. A regra que rege tudo: dia 0, não sprint futuro

O anti-padrão que esta skill mata é **"começa simples e a gente coloca segurança/ops/testes
depois"**. Depois é nunca. O piso não é um marco no roadmap — é a **fundação**; a feature vem
**em cima** dele. Um projeto sem o piso não é um projeto da casa: é um protótipo, e protótipo
exige **ADR com data de virada** (§27), não um encolher de ombros.

## 1. Segurança (piso comum, inegociável)

Vem montado, valha qual linguagem for:

- **Segredo nunca no cliente** (nem em `NEXT_PUBLIC_`/`VITE_`/`PUBLIC_`, nem no bundle, nem no
  repo). Segredo real via secret manager referenciado pelo seed do ops.
- **Consulta sempre parametrizada** — sem SQL/query por concatenação/interpolação.
- **Auth decidida no servidor** (deny-by-default); token em cookie HttpOnly, nunca localStorage.
- **Validação de input** na fronteira; sem erro engolido; sem coerção silenciosa de tipo.
- Detalhe em `schematize-engineering/references/seguranca.md` e `anti-padroes.md` (§37).

## 2. Testes de verdade + pentest de rejeição

- **Test kit** que roda pelo ops, saída machine-readable, categorias (unit/componente/e2e/
  integração). "Verde de verdade" = a suíte roda **hoje**, sem `.skip`/assert comentado.
- **Pentest prova rejeição, rota por rota, campo por campo:** nunca 500 por input hostil, nunca
  coerção de tipo, nunca eco sem escape, nunca vazamento cross-tenant. Base em
  `schematize-qa` → `references/estrategia.md` e `references/execucao.md` (a disciplina de teste saiu
  da engineering na extração da Q.A.); arsenal na
  `schematize-pentest`.
- **Matriz de acesso por rota desde o PRIMEIRO endpoint** (piso 20 da engineering): toda rota nasce com teste unit/componente das 4 personas (anônimo, autenticado não privilegiado, privilegiado, burlas), status **e** corpo, deny-by-default, allowlist de rotas públicas com dono, inventário derivado do código/spec e gate **M == N** no CI (`schematize-qa` → `scripts/check-route-authz.sh`). O scaffold planta o esqueleto da matriz e o gate no CI; **rota sem linha na matriz quebra o build**. O ofensivo periódico é a `schematize-pentest`.
- O scaffold cria a **estrutura de testes** e o alvo de CI no dia 0 — não um `TODO: add tests`.

## 3. IAM baseline 2FA (app separada — o coração do piso)

O auth (`<projeto>_auth_<lang>` + `<projeto>_authfront`, `references/estrutura.md` §4) nasce com o
**baseline** da casa:

- **Identidade ≠ autorização.** `sub` = **ID interno imutável e opaco** (ULID/UUIDv7). **Email e
  telefone NUNCA são ID** — são identificadores, cada um com estado de verificação; **1..N por
  usuário** (ter mais de um email é incentivado).
- **≥ 2 fatores por desenho, desde o cadastro.** Senha (**argon2id** + checagem contra vazadas/
  HIBP) **+ Email OTP** (Resend, always-on) **já é 2FA baseline válido**. Fator forte é
  incentivado just-in-time (step-up), **nunca muro pré-login**.
- **Passkey/WebAuthn é núcleo** (phishing-resistant, "2 fatores num"), não roadmap. Twilio pra
  SMS/voz; provedores plugáveis (`EmailProvider`/`SmsProvider`/`PushProvider`).
- **Passkey/WebAuthn é o método PADRÃO e entra na FASE 0 do projeto** (piso 21 da engineering): registro e asserção reais ponta a ponta no `auth.<domain>` **antes de qualquer feature**; passwordless-first (senha + Email OTP fica de fallback/2FA baseline). Teste obrigatório: registro, login, challenge reutilizado, origin/rpId errado e credencial revogada rejeitados. A implementação mora no IAM da casa (`schematize-iam`); o app cliente só integra por OIDC/PKCE + passkey (`schematize-web` `/web-iam`, `schematize-mobile` `/mobile-auth`).
- **Recuperação tão forte quanto o login** (nada de reset por 1 email que passa por cima do 2FA);
  **SSO nunca é ponto único de falha** (força ≥1 fator de recuperação local); account-linking
  explícito e anti-takeover.
- **ReBAC multi-tenant granular, deny-by-default, enforcement sempre no servidor.** Sessão longa
  com logout irreversível.
- Delegação **OIDC/OAuth2.1 + PKCE**; chave só no auth, validação por **JWKS**.
- Base completa em `schematize-engineering/references/iam.md`. O `/<prefixo>-iam` da skill de *(o prefixo NÃO se deriva do nome da skill — a tabela de `references/linguagem.md` tem a coluna; em C# é `/cs-iam`.)*
  linguagem scaffolda a implementação.

## 4. Ops / isolamento por app + CI com deploy gated

O `<projeto>_ops` (control plane, `references/estrutura.md` §6) nasce com os invariantes:

- **Fluxo de promoção fixo, sem atalho:** `dev local → teste local (verde) → GitHub → hml → prd`.
  Nada pula etapa; **VETADO editar código direto no servidor**; hotfix segue o mesmo fluxo
  acelerado. Servidor é **imutável por edição manual** — só recebe artefato com **proveniência
  git** (commit SHA).
- **Deploy destrutivo por seed:** o ops provisiona em `/<app>/` clonando os repos dentro;
  `/<app>/.env` é o **seeder global** (fonte única de config); todo redeploy **apaga a
  implantação anterior e recria um clone zerado** só com o seed (idempotente, sem drift) —
  **preservando os dados** (migration reversível com `down`; `ops reset` de dados só em dev/hml).
- **Isolamento por app:** **um user Linux dedicado por serviço** (nunca dois no mesmo, nunca
  `root`) + **um systemd unit hardened** (`NoNewPrivileges`, `ProtectSystem=strict`,
  `ProtectHome`, `PrivateTmp`, `ReadWritePaths` mínimo, `CapabilityBoundingSet` mínimo). Blast
  radius contido: comprometer um serviço não vaza pros outros nem pro host.
- **100% das operações passam pelo ops** (`bootstrap`/`install`/`redeploy`/`update`/`config`/
  `migrate`/`health`/`rollback`/`logs`/`reset`/`test`), idempotente, com `--help`. Nada de
  `ssh` + comando ad-hoc.
- **Instalação SEMPRE paralela** (grau = `nproc`); falha no paralelo = **bug de independência**
  (prioridade máxima), corrigido de verdade — **nunca** mascarado serializando.
- **CI com deploy gated:** o pipeline roda o test kit + gate da DoD e **só promove o que passou**;
  a promoção pra hml/prd é gated pelo fluxo acima. Base em
  `schematize-engineering/references/ops.md` + `operacao.md` (§21).

## 4.1 Banco de dados — o schema é peça do dia 0

O piso não tinha banco, e banco é onde o erro de dia 0 fica **mais caro**: schema errado se corrige
com migração em produção, não com refatoração.

**O que nasce junto com o projeto:**

- **Um banco (ou schema) por serviço** — o serviço não alcança o dado do vizinho; cross-service é
  por **API/evento**, nunca por tabela compartilhada (`schematize-infra` → `references/isolamento.md`).
- **Schema desenhado, não improvisado:** `schematize-database` (`/database-design`) — PK surrogate
  **ULID/UUIDv7** (id sequencial exposto é VETADO), chave natural em `UNIQUE`, **PII fora do índice
  em claro**, dinheiro em `numeric`, tempo em `timestamptz`.
- **Migração desde a primeira tabela**, versionada no repo e **reversível** (`up`/`down` testado),
  no fluxo **expand → migrate → contract**. A primeira migração é `0001`, não "depois a gente
  organiza".
- **Compose de dev com o banco real** (mesma major que produção) + **Mailpit** para o efeito externo
  (§9). Banco de dev diferente do de produção é bug esperando o deploy.
- **Credencial do banco pelo seeder** (`/<app>/.env`), nunca no código nem no compose commitado; e
  **usuário de aplicação sem privilégio de DDL** em produção.
- **Backup com restore ensaiado** desde o começo — o `dr-drill` da `schematize-infra` é o gate, e
  *backup cujo restore nunca foi provado não é backup*.

## 5. Observabilidade integrada

Todo serviço — e o próprio ops — sobe com **observabilidade integrada** (logs estruturados,
métricas, tracing; stack tipo Grafana/LGTM+). Endpoint de saúde responde; dashboard/alerta
versionado como código. Não é "instrumenta depois de dar problema"; nasce instrumentado. Base em
`schematize-engineering/references/observabilidade.md` (§16).

## 6. Definition of Done (§DoD) como gate

Toda entrega passa pela **Definition of Done (§35)**: testes verdes, sem anti-padrão (§37),
archive gerado, índice atualizado, gate de review (`/<slug>-review`) passa. O scaffold instala a
DoD como **gate de PR/entrega** no dia 0 — não fecha "quase pronto". Pisos de código junto:
arquivos **≤ 750 linhas** (~500 úteis + ~250 comentário; flag > 300 úteis), **uma unidade lógica
por arquivo**, **toda função com doc-comment**. Base em
`schematize-engineering/references/entrega.md` (§35) + `padroes-codigo.md`.

## 7. Archive / índice (MAPA §39)

`<projeto>/<projeto>_archive/` existe **no primeiro commit** — **dentro** do diretório do projeto,
irmão dos diretórios de microserviços.

- **A planta é UMA, e não é definida aqui:** `schematize-archive` → `references/archive.md` é a
  **canônica** (pastas, convenção de nome, o que nunca entra, retenção, recuperação). *Havia três
  layouts concorrentes no catálogo, e o efeito era um ADR gravado num lugar e procurado noutro; a regra
  agora é uma planta só, a da `schematize-archive`.*
- **É um repositório git PRÓPRIO e PRIVADO** (`gh repo create <org>/<projeto>_archive --private`),
  não uma pasta dentro do repo do serviço e não algo gitignorado. **Privado** porque ele guarda
  transcript de sessão; **próprio** porque é o que faz o rastro **sobreviver à perda da máquina** —
  archive que só existe no seu disco não é criticidade 0, é uma pasta.
- Toda entrega gera o `.md` de archive (§28); o `MAPA.md` + índice de microfunções (§39) moram no
  archive (`/eng-index` regenera dos doc-comments); o **root fica limpo**.
- Rode **`/archive-init`** no dia 0 (cria a estrutura **e** o repo com remote privado) e
  **`/archive-check`** antes de commitar (segredo, PII, binário, convenção).

Sem archive, a entrega não aconteceu. Base em `schematize-engineering` -> `references/operacao.md`
(§28, §39); planta e ciclo de vida em `schematize-archive`.

## 8. Overdev ligado

O projeto nasce com o **overdev disponível** (`/eng-overdev`): Fase 0 (decisões→grafo→plano
pesado→checklist) e o laço que não deixa parar com item aberto. O bootstrap é, ele mesmo, um bom
primeiro alvo de overdev — o piso inteiro vira um checklist exaustivo que só fecha **provado**.
Base em `schematize-engineering/references/overdev.md`.

### 8.1 Orquestração barata herdada (não é peça nova do check)

Todo projeto novo herda o piso **"Orquestrador não desenvolve; subagent barato executa"**
(`schematize-engineering` → `references/orquestracao.md` §9): o agent principal só planeja,
decompõe, despacha, supervisiona e revisa; ação onerosa vira micro-tasks/micro-funções executadas
por subagents em `sonnet` por padrão (falhou → mesmo subagent corrige ≤2 rodadas → re-decompõe →
só então `opus`, motivo registrado). O `CLAUDE.md` que o scaffold gera carrega esse piso (via
`/<slug>-claude`); o overdev do bootstrap já sai com o checklist em itens de micro-task com tag
`[sonnet]`/`[opus: motivo]` (`schematize-overdev-context`).

## 9. Efeito externo: SINK por default — o piso vira default de FÁBRICA

O projeto novo **nasce seguro**: aqui é onde o piso "efeito externo nunca sai de não-produção"
(normativa: `schematize-engineering` → `references/efeitos-externos.md`) deixa de depender de
alguém lembrar e vira **default de fábrica**. Quem scaffolda decide, **uma vez**, o que o projeto
faz por padrão — e o padrão da casa é **não chegar em ninguém fora de `prd`**.

**Motivo (registre no ADR/README do projeto):** um laço de teste disparou **>5.000 e-mails reais**
pra endereços sintéticos — hard bounce e spam trap em massa, **reputação de IP e domínio
queimada**, o transacional de **produção** parando de chegar (inclusive o **OTP de login** — e o
IAM da casa é **Email OTP always-on**, §3), **semanas de warm-up**, utilidade **zero**. Não tem
undo. Um projeto que nasce com o provider real ligado por default já nasce com essa bomba armada.

### 9.1 O `.env.example` / seed que o scaffold gera

O `.env.example` (e o seed `/<app>/.env` do ops) já vem com as quatro chaves — **preenchidas**,
não comentadas "pra quando precisar":

```bash
# --- Ambiente (fail-closed: ausente/ilegivel => assume NAO-producao) ---
APP_ENV=dev                          # dev | hml | prd

# --- Efeito externo: piso da casa (schematize-engineering/references/efeitos-externos.md) ---
MAIL_PROVIDER=sink                   # DEFAULT DE FABRICA. so 'prd' troca por provedor real
MAIL_SINK_URL=http://localhost:8025  # Mailpit: API HTTP pro teste LER a caixa
TEST_MAIL_DOMAIN=test.<domain>       # dominio em ROTA NULA (null MX + SPF -all + DMARC p=reject)
MAIL_MAX_PER_RUN=50                  # cap por execucao; estourou, ABORTA (nao "avisa")
MAIL_FROM=nao-responda@mail-hml.<domain>   # subdominio de envio SEPARADO por ambiente
# MAIL_API_KEY: nunca aqui. Cofre, e SANDBOX fora de prd (schematize-infra/segredos.md §7)
```

- **`MAIL_PROVIDER=sink` é o default**, e a troca pro provedor real é **config de `prd`**, não
  flag que qualquer um liga em dev. O mesmo vale pra `SMS_PROVIDER`, `PUSH_PROVIDER`,
  `WEBHOOK_TARGET` e a chave do PSP (**test key**, sempre).
- **`.env.example` nunca carrega chave de provedor real** — nem "comentada pra facilitar"
  (`references/piso.md` §1: segredo nunca no repo).
- O **guard mora dentro do provider** (destinatário fora do `TEST_MAIL_DOMAIN` com `APP_ENV != prd`
  → **erro**, não warning), e o scaffold cria o **teste que vê o vermelho**: tenta `@gmail.com` em
  hml e **espera a recusa**. Provider sem esse teste é peça **parcial** no check.

### 9.2 O `docker-compose` de dev já sobe o Mailpit

Sink não é um plano — é um container que **já está no compose** do dia 0:

```yaml
services:
  mailpit:
    image: axllent/mailpit@sha256:<digest>   # pinado por digest (nunca :latest)
    ports:
      - "8025:8025"   # UI + API HTTP: o teste LE a caixa por aqui
      - "1025:1025"   # SMTP do sink - o unico destino de e-mail em dev
    environment:
      MP_MAX_MESSAGES: 5000
    restart: unless-stopped
```

O e2e assere **na caixa do sink** (`GET /api/v1/messages`), não em "confia que mandou". É isso que
torna o sink **melhor** que o provedor real em teste: determinístico, offline, sem custo, sem
reputação em jogo.

### 9.3 O resto do piso que o scaffold planta junto

- **Fixture/seed/factory/persona/demo/carga** só emitem `<papel>+<run-id>-<n>@test.<domain>`.
  **VETADO** no template gerado: `@gmail.com`/`@hotmail.com`/`@outlook.com` e afins, domínio de
  terceiro/cliente, **e-mail de pessoa real (inclusive o seu)** e o **domínio de produção**.
- **Gate no CI do dia 0:** `.claude/skills/schematize-scaffold/scripts/check-external-effects.sh`
  plugado no pipeline — trava em endereço de caixa real em `test*/`/`seed*/`/`fixtures/`, em chave
  de provedor não-sandbox no `.env` de não-prd e em envio sem cap.
- **O DNS do domínio de teste é tarefa do dia 0**, não "depois que subir": null MX + SPF `-all` +
  DMARC `p=reject` declarados na IaC e **provados por `dig`** (`schematize-infra` → `iac.md` §7).
  O scaffold **abre o item**; a infra o fecha.
- Entregar de verdade fora de `prd` exige **as cinco** (ADR + allowlist ≤5 + cap + janela +
  subdomínio separado) — nenhuma delas é default de scaffold.

## 10. Tabela-resumo do piso (o que o check procura)

| # | Peça do piso | Presença mínima no dia 0 |
|---|---|---|
| 1 | Segurança | segredo fora do cliente, query parametrizada, auth server-side, validação na borda |
| 2 | Testes + pentest | test kit rodando + estrutura de pentest de rejeição |
| 3 | IAM baseline 2FA | `<projeto>_auth_<lang>` + `authfront` separados, ID≠email, senha+OTP, passkey, ReBAC, OIDC/JWKS |
| 4 | Ops / isolamento / CI gated | `<projeto>_ops` com promoção, seed, user+systemd por app, `nproc`, CI que só promove verde |
| 5 | Observabilidade | logs/métricas/tracing + health endpoint desde o boot |
| 6 | DoD (§DoD) | gate de entrega (review + testes + archive) ligado |
| 7 | Archive/índice | `<projeto>_archive/` + MAPA/índice (§39), root limpo |
| 8 | Overdev | `/eng-overdev` disponível; bootstrap como checklist |
| 9 | Efeito externo (sink de fábrica) | `MAIL_PROVIDER=sink` default, `TEST_MAIL_DOMAIN`, `MAIL_MAX_PER_RUN`, guard no provider, Mailpit no compose |
| 10 | Matriz de acesso por rota | teste das 4 personas por rota (status e corpo), deny-by-default, allowlist de públicas, gate M == N no CI (`scripts/check-day0-auth.sh`) |
| 11 | Passkey na fase 0 | registro+asserção reais e2e no `auth.<domain>`; testes de challenge reutilizado, origin/rpId errado e credencial revogada (`scripts/check-day0-auth.sh`) |
