# Estrutura canônica — como um projeto novo da casa é organizado

> Um projeto novo **não é um repo** — é um **workspace** com um conjunto de repos irmãos, cada um
> um bounded context, mais o auth (app separada), o front, o ops (control plane) e o archive. Este
> reference define a topologia inicial que o `/scaffold-new` instancia. A base normativa está em
> `schematize-engineering/references/arquitetura.md` (§2), `iam.md` (§1) e `ops.md`.

## 1. O workspace é a pasta do projeto (contenção)

O **diretório de projeto atual é o workspace**; toda aplicação/repo do sistema **nasce e mora
dentro dele**. Vai criar uma aplicação nova? crie uma **pasta pra ela dentro da pasta atual**
(`./<projeto>_<ctx>/`) e trabalhe lá. Os repos são **irmãos dentro do mesmo workspace** (clonados
ali pelo `<projeto>_ops`), **nunca** espalhados pela máquina.

**VETADO** no scaffold: largar arquivos soltos no root pra depois `cd ..` e criar os outros repos
fora; criar/ler/escrever no diretório-pai, `~`, `~/Downloads`, `/tmp` do usuário, Área de
Trabalho. O agente **não sai da pasta do projeto** — a menos que o usuário peça explicitamente.

## 2. Nome dos repos — `<projeto>_<ctx>_<lang>`

Um **repositório = uma aplicação ou um bounded context**. O nome espelha isso, em snake_case
minúsculo:

```
<projeto>_<contexto>[_<lang>]
```

- `<projeto>` = slug do produto/organização (ex.: `payle`, `loja`).
- `<contexto>` = a aplicação/bounded context daquele repo (`api`, `core`, `worker`, `gateway`,
  `front`, `auth`, `authfront`, `ops`…).
- `_<lang>` = sufixo **opcional** pra desambiguar linguagem: `_rs` Rust, `_go` Go, `_ex` Elixir,
  `_cs` C#, `_zig` Zig, `_rb` Ruby, `_ts` TypeScript. **O front NÃO leva sufixo** (`<projeto>_front`) — é regra, não hábito.

Exemplos: `payle_core_rs`, `payle_worker_go`, `payle_front`, `payle_auth_rs`, `payle_authfront`,
`payle_ops`.

## 3. A topologia mínima do dia 0

Todo projeto novo da casa nasce, no mínimo, com este conjunto — **cada um é um repo/pasta irmã**
dentro do workspace:

| Repo/pasta | Papel | Piso que carrega |
|---|---|---|
| `<projeto>_<ctx>_<lang>` (1..N) | os bounded contexts do produto (o "core" do negócio) | arquitetura/DDD, segurança, testes, observabilidade, archive |
| **`<projeto>_auth_<lang>`** | o **IdP da casa** — microserviço de autenticação, **app separada** | IAM baseline 2FA, OIDC/OAuth2.1+PKCE, JWKS, ReBAC |
| **`<projeto>_authfront`** | o **front do auth** (login/registro/recuperação/gestão de fatores) | frontend seguro (segredo server-side, a11y) |
| **`<projeto>_front`** | o **front do produto** — separado do backend | `schematize-web` (fronteira client/server, CWV, i18n) |
| **`<projeto>_ops`** | o **control plane** de operação/instalação do workspace | fluxo de promoção, seed, isolamento por app, `nproc` |
| **`<projeto>_archive`** | o rastro durável: decisões, planos, handoffs, índice/MAPA, ADRs | archive §28, índice §39 |

> Projetos maiores acrescentam mais contextos (`_worker`, `_gateway`, `_ledger`…) — sempre um
> repo por contexto, sempre irmão no workspace. O que **nunca** falta: **auth (app separada) +
> authfront + front + ops + archive**, desde o dia 0.

## 4. Auth é uma APLICAÇÃO SEPARADA (não negociável)

O buraco clássico é "coloco o login no core agora e separo depois". Aqui **não**: o auth nasce
separado.

- **Microserviço de auth** (`<projeto>_auth_<lang>`) **+ front de auth próprio**
  (`<projeto>_authfront`), com **repo, deploy, user Linux e systemd/container isolados**, servido
  em **`auth.<domain>`**. Comprometer o app principal **não** compromete o IdP.
- **O app principal (e todo cliente) delega ao auth por OIDC/OAuth2.1 + PKCE:** redireciona pra
  `auth.<domain>`, recebe tokens de volta. O auth é o **IdP da casa** (self-hosted, consumido por
  N apps).
- **Segredos e a chave de assinatura de token vivem SÓ no auth**; consumidores validam por
  **JWKS público**, nunca guardam a chave privada.
- **Fit de linguagem:** auth/cripto → **Rust** (default quando errar é caro), e o empate resolve em **Go** — mas a
  escolha vira ADR (`references/linguagem.md`). O `<projeto>_authfront` é `schematize-web`.

O detalhe do modelo de identidade (ID≠email, ≥2 fatores, passkey núcleo, ReBAC multi-tenant) está
no piso — `references/piso.md` §3 e `schematize-engineering/references/iam.md`.

## 5. Front separado do backend

O front do produto (`<projeto>_front`) e o front do auth (`<projeto>_authfront`) são **repos
próprios**, governados pela `schematize-web`. O server-side do próprio front (route
handlers/server actions/BFF) **faz parte do frontend** — mas isso **não** reabre Node como
serviço backend. Segredo só server-side, nunca em `NEXT_PUBLIC_`/`VITE_`/`PUBLIC_`.

## 6. `<projeto>_ops` — o control plane, desde o dia 0

O `<projeto>_ops` é a **interface única** de operação do workspace: bootstrap (cria `/<app>/` e
clona os repos), instalação **paralela** (`nproc`), deploy **destrutivo por seed** (`/<app>/.env`),
isolamento por app (user Linux + systemd hardened), fluxo de promoção. Não é microserviço do
produto nem é deployado com ele — é a ferramenta que **sobe e opera** o sistema. Detalhe no piso
(`references/piso.md` §4) e em `schematize-engineering/references/ops.md`.

## 7. Independência de runtime (fronteira que o scaffold já respeita)

Todo serviço **sobe e opera sozinho**. A indisponibilidade de qualquer outro serviço **nunca**
impede o boot nem derruba este. Depender de outro serviço pra *iniciar* é VETADO — dependente
ausente vira **degradação graciosa** (fallback, outbox/retry, enfileira e segue), nunca crash em
cascata. O scaffold nasce com essa fronteira: nada de "o `ledger` não sobe se o `core` estiver
fora". É o que faz a instalação paralela do ops funcionar (`references/piso.md` §4).

## 8. O que o root de cada repo tem (limpo)

O root de cada repo fica **limpo**: código, config, `README.md`, `CLAUDE.md`, `LICENSE`. **Todo
MD gerado** (MAPA, índice, plano, relatório, handoff, ADR) mora em `<projeto>_archive/`, nunca no
root (§28). O `/scaffold-new` já cria o repo com essa higiene.
