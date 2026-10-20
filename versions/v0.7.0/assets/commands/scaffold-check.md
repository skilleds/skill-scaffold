---
description: schematize-scaffold — audita um projeto EXISTENTE contra o piso do dia 0 (IAM app-separada, ops/isolamento, CI gated, testes/pentest, DoD, archive/índice, overdev), com prova; gera checklist de saneamento e trava se faltar peça
argument-hint: "[dir do projeto/workspace, ex: .]"
---

Rode o **scaffold-check** (`references/check.md`): o projeto em `${ARGUMENTS:-.}` **tem o piso da
casa?** Enumera cada peça, verifica presença **com prova de hoje**, aponta o que falta e gera o
checklist de saneamento. Pareia com a `schematize-audit` (aqui auditamos o **piso**; lá, se os
**checklists criados** foram sanados). O check é **read-mostly** — aponta e gera o conserto, não
conserta.

## 1. Inventário do workspace (`references/estrutura.md` §3)
Liste os repos irmãos (`ls`) e identifique o papel de cada um (core/auth/authfront/front/ops).
Cruze com a topologia esperada: falta `<projeto>_auth_<lang>`? falta `<projeto>_authfront`? falta
`<projeto>_ops`? falta `<projeto>_archive`? Cada ausência é um achado.

## 2. Prove peça por peça (`references/check.md` §1) — presença exige PROVA
Para cada uma, veredito `present` / `missing` / `partial`, com origem (`repo:caminho`) e o que
falta. "Tem uma pasta `auth`" **não** prova IAM baseline — o que prova é ID≠email + ≥2 fatores +
OIDC + JWKS **rodando** (mesma disciplina do "suspeito ≠ achado"). Parcial conta como falta.

1. **Segurança** — sem segredo no cliente/repo; query parametrizada; auth server-side; validação.
2. **Testes + pentest** — test kit **verde hoje**; testes de rejeição/authz existem.
3. **IAM app separada** — `<projeto>_auth_<lang>` **+** `authfront` (repos próprios); delegação
   OIDC; ID≠email; ≥2 fatores; JWKS. *(prioridade 0)*
4. **Ops / isolamento / CI gated** — `<projeto>_ops`; promoção; seed `/<app>/.env`; user+systemd
   por serviço; `nproc`; CI só promove verde.
5. **Observabilidade** — health endpoint; logs/métricas/tracing versionados.
6. **DoD (§35)** — gate de PR/entrega (review + testes + archive).
7. **Archive/índice** — `<projeto>_archive/` usado; `MAPA.md`/índice (§39); root limpo.
8. **Overdev** — `/eng-overdev` disponível; histórico de checklist no archive.
9. **Efeito externo não sai de não-produção** *(a 9ª peça — e a que mais reprova em projeto
   existente)*. Prove **as quatro**, não uma:
   - **provider default = SINK** fora de `prd` (`MAIL_PROVIDER=sink`/adapter local no
     `.env`/config de cada ambiente que não é produção);
   - **guard deny-by-default DENTRO do provider**, com **teste que vê a recusa** (não basta o
     provider estar sinkado: o guard é o que segura quando alguém troca a config);
   - **cap por execução** (`MAIL_MAX_PER_RUN`) — e ele vale em **todos** os ambientes;
   - **domínio de teste em ROTA NULA** (`TEST_MAIL_DOMAIN=test.<domain>` com **null MX**), e
     **nenhum** `@gmail.com`/`@hotmail.com`/e-mail de pessoa real em seed, fixture ou persona.

   **Como provar hoje:** `bash .claude/skills/schematize-scaffold/scripts/check-external-effects.sh .` → exit 0; e o teste do guard
   rodando e **falhando de propósito** uma vez. *(Esta peça existia no `SKILL.md` e no `CLAUDE.md`
   da skill e **faltava aqui** — o comando enumerava 1..8 e parava, uma regressão do próprio
   v0.2.0. Achado da vistoria de 2026-08-21.)*
10. **Matriz de acesso por rota** — teste unit/componente das 4 personas (anônimo, não
    privilegiado, privilegiado, burlas) por rota do inventário, status e corpo; deny-by-default;
    allowlist de públicas com dono; `check-route-authz.sh` (M == N) no CI.
11. **Passkey na fase 0** — registro+asserção reais e2e no `auth.<domain>`; testes de challenge
    reutilizado, origin/rpId errado e credencial revogada rejeitados.
    **Como provar hoje (10 e 11):** `bash .claude/skills/schematize-scaffold/scripts/check-day0-auth.sh .` → exit 0.

Cheque também: todo serviço tem **ADR de linguagem** `accepted`? backend novo fora do rol
(Node/PHP) sem ADR de exceção é achado (`references/linguagem.md`).

## 3. Checklist de saneamento (`references/check.md` §3)
Cada peça `missing`/`partial` vira um item (candidato a `/eng-overdev`) com o comando que resolve
(scaffoldar auth via `/<prefixo>-iam`, ops via `/<prefixo>-ops`, amarrar CI ao fluxo, criar archive + *(o prefixo NÃO se deriva do nome da skill — ver `schematize-engineering → references/linguagens.md`; em C# é `/cs-iam`.)*
`/eng-index`, gravar ADR retroativo). Se for **legado** (Node/PHP backend), o saneamento é
**strangler-fig por módulo** com o piso na saída — mas **prioridade 0 é IAM + segurança**.

## 4. Gate (`references/check.md` §4)
Piso são = **zero peças `missing`/`partial` do dia 0** (segurança, IAM app-separada, ops/CI gated,
testes, DoD, archive). **IAM e segurança são prioridade 0** — projeto sem IAM app-separada **não
passa**. O check **não fecha** peça (não marque presente sem prova); quem conserta é o run de
saneamento, e depois **rode o check de novo**. Grave o relatório em
`<projeto>_archive/scaffold/<data>.md` (nunca no root).

## Quando rodar
Ao adotar um projeto que não nasceu com o scaffold; due diligence de repo herdado; antes de
marco/release; e quando a `schematize-audit` apontar dívida que cheire a "nasceu sem o piso".
