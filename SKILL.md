---
name: schematize-scaffold
metadata:
  version: 0.6.0
description: >-
  Blueprint de PROJETO NOVO: piso do dia 0 (workspace, archive, IAM app separada, linguagem por fit + ADR, repos, CI/CD, observabilidade). Use ao começar projeto/repo ou checar o piso.
---

# O scaffolder da casa (schematize-scaffold)

Disciplina normativa, **agnóstica de linguagem**, que responde a uma pergunta só: **como um
projeto novo da casa NASCE?** A resposta não é "com um `main` que responde 200" — é **com o piso
inteiro montado no dia 0**. Esta skill é o **blueprint executável** desse nascimento: a estrutura
canônica, o piso de fábrica e o checklist de bootstrap que transformam "pasta vazia" em "sistema
da casa em pé".

É o **blueprint do dia 0** da casa: onde a `schematize-engineering`
descreve *o que* é o piso (arquitetura, IAM, ops, DoD, archive), esta skill descreve *como
instanciá-lo* num projeto do zero — e como **auditar** (`scaffold-check`) se um projeto existente
o tem. O antídoto ao "começa sem IAM/sem ops que a gente coloca depois" — porque **depois é
nunca**, e "nunca" é um sistema inseguro em produção.

**Versão:** skill `schematize-scaffold` v0.6.0. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:dominio intro="Esta skill é o recorte **projeto novo (piso do dia 0)** da base: instancia o piso que a `schematize-engineering` descreve, sem reescrevê-lo." cmd="scaffold" -->Esta skill é o recorte **projeto novo (piso do dia 0)** da base: instancia o piso que a `schematize-engineering` descreve, sem reescrevê-lo.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização do domínio ou da
   ferramenta — o como, o padrão, o gate. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Esta skill herda os pisos da base e
   os comandos dela cobrem o **domínio**, não o piso geral. Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/scaffold-*` cobrem o domínio desta skill; o piso geral é o da base.<!-- /herdado -->

## Comandos (Claude Code)

Digite `/scaffold-help` pra ver todos. Em resumo:

| Comando | O que faz |
|---|---|
| `/scaffold-help` | lista todos os comandos do schematize-scaffold |
| `/scaffold-new` | o passo-a-passo de **criar projeto novo** já com o piso do dia 0: nomeia os repos por contexto, escolhe linguagem (fit + ADR), scaffolda `auth`/`authfront`/`front`/`ops`, monta CI gated, IAM baseline, observabilidade, archive/índice e liga o overdev |
| `/scaffold-check` | roda contra um **projeto existente** e aponta **o que falta do piso** (IAM app-separada? ops/isolamento? CI gated? DoD? archive/índice? overdev?) — emite checklist de saneamento e trava se faltar peça do dia 0 |
| `/scaffold-load` | carrega à força TODO o corpo normativo (estrutura, piso, linguagem, bootstrap, check) e passa a aplicá-lo |
| `/scaffold-claude` | cria ou mescla o `CLAUDE.md` sempre-on do scaffold na raiz do repo |
| `/scaffold-cc` | context compact: gera handoff no archive e roda `/compact` |
| `/scaffold-handoff` | gera o handoff (context.md + checklist.md) sem compactar |

Os comandos ficam em `assets/commands/` e são instalados em `.claude/commands/`.

## Como usar esta skill

1. **Projeto novo? plan-first sempre** (`/scaffold-new`): antes de criar pasta, fixe a
   **topologia** (quais bounded contexts, que repos, qual linguagem por serviço) e o **ADR
   inicial** de linguagem. Scaffoldar sem decidir a fronteira é montar um monólito por acidente.
   Leia `references/estrutura.md` e `references/linguagem.md`.
2. **Monte o piso do dia 0** (`references/piso.md`): IAM app-separada, ops/isolamento,
   observabilidade, CI gated, testes/pentest, DoD, archive/índice, overdev. **Nada é "pra
   depois".** O checklist de bootstrap está em `references/bootstrap.md`.
3. **Projeto existente?** (`/scaffold-check`, `references/check.md`): audite contra o piso, item
   por item, e gere o **checklist de saneamento** do que falta. Pareia com a `schematize-audit`.
4. **Não trabalhe de memória** — a estrutura canônica, o piso e o bootstrap estão nos references.
   A implementação idiomática de cada peça (o auth em Rust, o front em Next, o ops em Go) sai da
   **skill de linguagem** escolhida (`schematize-rust`/`web`/`go`/...). Aplique os pisos abaixo
   independentemente do reference carregado.

Mapa de references — leia o que casa com a tarefa:

| Tarefa | Reference |
|---|---|
| A **estrutura canônica**: repos por contexto (`<projeto>_<ctx>_<lang>`), auth como app separada (`<projeto>_auth_<lang>` + `<projeto>_authfront`) + delegação OIDC, front separado, `<projeto>_ops`, `<projeto>_archive`, contenção no workspace | `references/estrutura.md` |
| O **piso de fábrica** que vem no dia 0: segurança, testes+pentest, IAM baseline 2FA, ops/isolamento por app, observabilidade, CI com deploy gated, DoD §DoD, archive/índice, overdev | `references/piso.md` |
| A **escolha de linguagem** por fit + o **ADR inicial** (rol sancionado Go/Rust/Elixir/C#/Zig/Ruby; front Node) | `references/linguagem.md` |
| O **checklist de bootstrap**: a ordem de criar um projeto novo com o piso, passo a passo, do workspace ao overdev ligado | `references/bootstrap.md` |
| O **scaffold-check**: auditar um projeto existente contra o piso, o que conta como "tem o piso", o checklist de saneamento e o gate | `references/check.md` |
| A **integração com a GUI**: como uma skill vira botão na aba do projeto declarando `gui.json` na raiz — o mecanismo geral (Q.A. e Pentest são instâncias dele) | `references/gui.md` |

## Pisos inegociáveis (vetam o atalho)

Independente do reference, estes limites nunca são cruzados:

1. **O piso é DIA 0 — nada de "sem IAM/sem ops pra depois".** IAM (app separada), ops
   (isolamento por app), CI gated, testes/pentest, observabilidade, DoD, archive e overdev
   **nascem com o projeto**, não entram num sprint futuro. "Depois" é "nunca"; "sem segurança
   pra ir rápido" é dívida disfarçada de produtividade. Projeto sem o piso **não é projeto da
   casa**, é protótipo — e protótipo pede ADR que dê data de virada.
2. **Auth é APP SEPARADA desde o primeiro commit.** Todo projeto nasce com
   `<projeto>_auth_<lang>` (o IdP) **+** `<projeto>_authfront`, com repo/deploy/user/systemd
   próprios, servido em `auth.<domain>`; o app principal **delega por OIDC/OAuth2.1 + PKCE**.
   **VETADO** apensar auth ao escopo principal "por enquanto". Comprometer o app principal não
   pode comprometer o IdP.
3. **Um repo = um bounded context, dentro do workspace.** Repos no padrão
   `<projeto>_<ctx>_<lang>`, **irmãos dentro da pasta do projeto** (nunca soltos no root, nunca
   `cd ..`). Front separado do backend. Nada de monólito que acopla contextos sem ADR de plano e
   **data** de quebra.
4. **`<projeto>_ops` nasce junto — control plane, não afterthought.** O sistema tem um
   `<projeto>_ops` desde o dia 0: bootstrap/instalação paralela (`nproc`), deploy destrutivo por
   seed (`/<app>/.env`), isolamento por app (user Linux + systemd hardened), fluxo de promoção
   (dev→teste→git→hml→prd). **100%** das operações passam por ele; nada de mão no servidor.
5. **Escolha de linguagem sai do ROL por fit + ADR inicial.** Backend novo em Go/Rust/Elixir/
   C#/Zig/Ruby, escolhido por **encaixe com o problema** e **registrado num ADR** no dia 0 —
   nunca por gosto. Front é Node (Next/Astro). O **piso é o mesmo em toda linguagem**; ela muda o
   "como", não o "o quê".
6. **Archive e índice desde o primeiro commit.** `<projeto>_archive/` existe no dia 0; toda
   entrega gera o `.md` de archive (§28), o `MAPA.md`/índice (§39) mora no archive, o **root fica
   limpo** (código, config, README/CLAUDE/LICENSE). Sem archive, a entrega não aconteceu.
7. **Overdev ligado e DoD como gate.** O projeto nasce com o overdev disponível (`/eng-overdev`)
   e a **Definition of Done (§35)** como gate de entrega. O scaffold não fecha "quase pronto": o
   bootstrap só termina quando o piso **inteiro** está de pé, provado (não auto-declarado).

8. **Projeto novo NASCE com o efeito externo em SINK** — `.env.example` com `APP_ENV`,
   `MAIL_PROVIDER=sink`, `TEST_MAIL_DOMAIN=test.<domain>`, `MAIL_MAX_PER_RUN=50`; Mailpit no compose
   de dev; guard dentro do provider (fail-closed) com teste que vê a recusa; nenhum provedor real
   ligado por default fora de `prd`. O `/scaffold-check` confere isso como **9ª peça**, com veto duro.
   Regra, motivo (incidente de >5.000 e-mails reais) e piso completo: `schematize-engineering →
   references/efeitos-externos.md`; scaffold: `references/piso.md` §9, `references/check.md`.

9. **IAM com passkey na FASE 0 e matriz de acesso por rota desde o primeiro endpoint.** Passkey/WebAuthn é o método PADRÃO (piso 21): registro e asserção reais ponta a ponta no `auth.<domain>` **antes de qualquer feature**; passwordless-first (senha + Email OTP fica de fallback/2FA baseline). Teste obrigatório: registro, login, challenge reutilizado, origin/rpId errado e credencial revogada rejeitados. Matriz (piso 20): toda rota nasce com teste unit/componente das 4 personas (anônimo, autenticado não privilegiado, privilegiado, burlas), status **e** corpo, deny-by-default, allowlist de rotas públicas com dono, inventário derivado do código/spec e gate **M == N** no CI (`schematize-qa` → `scripts/check-route-authz.sh`). O `/scaffold-check` confere como **10ª e 11ª peças** (`scripts/check-day0-auth.sh`).

10. <!-- herdado:engineering/orquestracao:bullet -->**Orquestrador não desenvolve; subagent barato executa** (`schematize-engineering` → `references/orquestracao.md` §9). O principal só planeja/decompõe/despacha/supervisiona/revisa; ação onerosa vira micro-tasks; principal = Claude Opus; executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código, até 2 rodadas de correção pelo mesmo subagent) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo no checkpoint) → `park`; **visual direto ao Codex; imagem nunca pelo Claude (pergunta ao usuário: Codex sugerido, ou Gemini), API de imagem paga PROIBIDA**; papéis configuráveis em `agentes.toml` (aba "Agentes" do overdev). No `overdev`, cada item do checklist é executado pelo papel adequado e revisado pelo principal (diff + gate) antes do `- [x]`. **Sem frota ociosa:** agent idle com pendência executável volta ao trabalho; pendência que depende de outro agent → mata e enfileira com gatilho de dependência; terminou → mata (§9.6).<!-- /herdado -->

## Relação com as outras skills

- **schematize-engineering** — a **BASE** que este scaffold materializa. Onde a engenharia
  descreve o piso (**arquitetura §2** repos/bounded context/ops, **IAM** app separada, **ops.md**
  isolamento/seed/promoção, **DoD §35**, **archive §28**, **índice/MAPA §39**, **overdev**), esta
  skill dá o **passo-a-passo de instanciá-lo do zero**. *(O blueprint é executado por `/scaffold-new`; não existe subcomando `schematize new` no CLI.)*

- **schematize-audit** — o **par de auditoria**. O `scaffold-check` verifica se o **piso do dia 0**
  está lá (IAM/ops/CI/DoD/archive); a `schematize-audit` verifica se **os checklists criados foram
  sanados**. O scaffold monta o piso; o audit prova que o que foi prometido depois foi entregue.
- **schematize-go / rust / elixir / csharp / zig / ruby** — a **implementação idiomática** de cada
  peça scaffoldada. O scaffold decide *que* o auth é app separada em Rust; a `schematize-rust`
  diz *como* escrever esse auth. Cada uma traz seu `/<prefixo>-iam` e `/<prefixo>-ops`, que
  scaffoldam a peça na linguagem (o prefixo não se deriva do nome da skill: ver
  `schematize-engineering → references/linguagens.md`; em C# é `/cs-iam`).
- **schematize-web** — o **front** (o do produto **e** o `<projeto>_authfront`): fronteira
  client/server, segredo só no servidor, a11y, CWV, i18n.
- **schematize-pentest** — o **oráculo de segurança**: o piso de IAM/authz que o scaffold monta é
  o que a pentest ataca rota por rota (rejeição, cross-tenant, IDOR/BOLA) pra provar que segura.

- **schematize-qa** — o **teste é peça do dia 0**, não coisa da fase 3. O scaffold monta o test kit
  antes da primeira feature: a pirâmide, o **smoke com self-check** (que prova que o runner sabe
  reportar FAIL — suíte que nunca falhou está cega), a matriz `simulated` de rota × persona, e os
  **gates de CI que travam o merge** desde o primeiro commit. Quem é dono do COMO é a
  `schematize-qa`; o scaffold só garante que a peça exista antes de haver dívida. Projeto que
  nasce sem gate de teste não ganha gate depois — ganha exceção.
- **schematize-archive** — a **planta do archive é dela**, não desta skill. A Fase 1 do bootstrap
  cria o `<projeto>_archive/` **rodando `/archive-init`**, com a árvore canônica da
  `schematize-archive` — inclusive o `git init` e o remote **privado**, que fazem parte
  do piso de criticidade 0. O scaffold decide *quando* (dia 0, antes do código); a
  `schematize-archive` decide *o quê* e *onde*.
