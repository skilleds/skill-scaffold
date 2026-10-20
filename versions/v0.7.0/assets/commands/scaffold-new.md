---
description: schematize-scaffold — cria projeto novo já com o piso do dia 0 (repos por contexto, IAM app-separada + OIDC, front, ops/isolamento, CI gated, DoD, archive/índice, overdev); é o lastro do `schematize new <projeto>`
argument-hint: "[slug do projeto, ex: payle]"
---

Crie um **projeto novo da casa** — que **já nasce** com o piso inteiro (`references/bootstrap.md`).
É o passo-a-passo de criar `${ARGUMENTS:-<projeto>}` já com o piso do dia 0. **Plan-first:** decida
a topologia **antes** de criar pasta. **Nada é "pra depois".**

## Fase 0 — Decidir (antes de `mkdir`) — `references/bootstrap.md` §0, `references/linguagem.md`
- **Slug** `<projeto>` (= `${ARGUMENTS}`), **domínio** `<domain>` (pra `auth.<domain>`).
- **Bounded contexts:** quais aplicações o produto tem — cada uma vira `<projeto>_<ctx>_<lang>`.
  Na dúvida, comece com **um** contexto bem-fechado (melhor que dois domínios colados).
- **Linguagem por serviço + ADR inicial** (`accepted`): fit → ADR. **Auth → Rust** (default por errar-caro); empate resolve em **Go**
  (errar é caro); core segue o fit (Go default pragmático); front é **Node**.
- **Grave o plano** em `<projeto>_archive/plan/<data>-scaffold.md` (topologia + ADRs + o checklist
  de bootstrap). Topologia grande? **peça aprovação**. Este é um alvo natural de `/eng-overdev`.

## Fase 1 — Workspace + archive — `references/estrutura.md` §1, `references/piso.md` §7
- Confirme a **contenção**: tudo nasce **dentro** da pasta atual (nada de `cd ..`).
- Crie `<projeto>_archive/` com a planta canônica da `schematize-archive` (ou rode `/archive-init`)
  — o rastro antes do código. A árvore tem **um dono só**; não a redefina aqui.

## Fase 2 — Auth PRIMEIRO (app separada) — `references/estrutura.md` §4, `references/piso.md` §3
- `<projeto>_auth_<lang>` — o **IdP**, servido em `auth.<domain>`, com o **baseline 2FA**:
  ID≠email (ULID/UUIDv7), senha argon2id+HIBP **+** Email OTP (já é 2FA), **passkey núcleo**,
  ReBAC multi-tenant, deny-by-default, **OIDC/OAuth2.1+PKCE**, chave só aqui + **JWKS**. Use o
  `/<prefixo>-iam` da linguagem. *(o prefixo NÃO se deriva do nome da skill — ver `schematize-engineering → references/linguagens.md`; em C# é `/cs-iam`.)*
- `<projeto>_authfront` — front de login/registro/recuperação/gestão de fatores (`schematize-web`).
- O app principal nasce **cliente OIDC** do auth — **nunca** login embutido.

## Fase 3 — Contextos do produto + front — `references/bootstrap.md` §3
- `<projeto>_<ctx>_<lang>` (1..N): segurança (segredo fora do cliente, query parametrizada, auth
  server-side, validação na borda), estrutura de testes+pentest, observabilidade, **delegação
  OIDC**, **independência de runtime** (sobe sozinho, degradação graciosa).
- `<projeto>_front` — front do produto (`schematize-web`), separado do backend.
- Root de cada repo **limpo** + `CLAUDE.md` aplicado (`/<slug>-claude`).

## Fase 4 — Ops (control plane) — `references/piso.md` §4
- `<projeto>_ops`: comandos idempotentes (`bootstrap`/`install`/`redeploy`/`update`/`config`/
  `migrate`/`health`/`rollback`/`logs`/`reset`/`test`), **fluxo de promoção** (dev→teste→git→
  hml→prd), **deploy destrutivo por seed** (`/<app>/.env`), **isolamento por app** (user Linux +
  systemd hardened por serviço), **instalação paralela** (`nproc`). Use o `/<prefixo>-ops`.

## Fase 5 — CI + DoD + observabilidade — `references/piso.md` §4–§7
- CI que roda test kit + gate da DoD e **só promove verde**; promoção hml/prd gated pelo fluxo.
- **DoD (§35)** como gate de PR em cada repo. Observabilidade (health/logs/métricas/tracing) em
  todo serviço + ops. Índice/**MAPA** (§39) gerado (`/eng-index`) e no archive.

## Fase 6 — Overdev + fechar provado — `references/bootstrap.md` §6
- Overdev disponível (`/eng-overdev`). Ao fim, **rode `/scaffold-check`** contra o próprio projeto
  novo: o bootstrap só termina com **zero itens do piso faltando** (provado, não auto-declarado).

## Piso (VETADO)
O piso é **dia 0**, não sprint futuro. Auth **app separada** desde o primeiro commit (OIDC/PKCE);
**um repo = um bounded context** no workspace; linguagem **por fit + ADR**; `<projeto>_ops` desde
o começo; archive/índice desde o primeiro commit. Projeto "sem IAM/sem ops pra depois" **não é
projeto da casa**.
