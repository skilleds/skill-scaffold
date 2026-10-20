# Escolha de linguagem — fit + ADR inicial (no dia 0)

> Um projeto novo escolhe linguagem **por serviço**, do **rol sancionado**, por **encaixe com o
> problema** — e a decisão vira **ADR** logo no dia 0. Este reference guia essa escolha no
> scaffold. A base é `schematize-engineering/references/linguagens.md`; o detalhe idiomático sai da
> skill irmã de cada linguagem.

## 1. O rol sancionado (backend)

A casa **não tem "a linguagem única"**; tem o rol e um guia de fit. Backend novo escolhe uma,
**com ADR (§27) justificando o fit**:

A tabela do rol (linguagem, skill, sufixo de repo, **prefixo de comando**, fit) vive em
`schematize-engineering → references/linguagens.md` — não é repetida aqui. Regra do scaffold: o
`/scaffold-new` resolve o sufixo do repo e o `/<prefixo>-iam` / `/<prefixo>-ops` por aquela tabela
(em C#: sufixo `_cs`, comando `/cs-iam`, não `/csharp-iam`).

**Frontend:** **Node** (Next.js principal; Astro e outros consolidados) — governado por
`schematize-web`. É **só frontend**; o server-side do próprio front não reabre Node como backend.

## 2. Fora do rol (não entram em projeto novo)

- **Node como serviço backend** e **PHP** **não recebem serviço novo** — são legado (migram por
  funcionalidade do módulo quando tocados). Projeto novo **não** os escolhe.
- **Nova linguagem fora do rol** exige **ADR de exceção** aprovado — não se adota por gosto.

## 3. Guia de fit — a decisão por serviço

Escolha por **encaixe**, não preferência. Regra de fit (do dia 0):

- **auth/cripto** → **Rust** (segurança de memória, input hostil). Encaixa o
  `<projeto>_auth_<lang>`; outra escolha exige ADR com o fit.
- **gateway/realtime/pub-sub** → **Elixir**.
- **serviço de rede/API/CLI/tooling** → **Go**.
- **utilitário de sistema/baixo nível** → **Zig**.
- **integração .NET/enterprise** → **C#**.
- **produto Rails / script / automação** → **Ruby**.

> **"Prototipagem rápida" saiu desta tabela de propósito.** Nesta skill, protótipo tem estatuto
> próprio: `piso.md` estabelece que *projeto sem o piso não é projeto da casa — é protótipo, e
> protótipo exige **ADR com data de virada** (§27)*. Oferecer uma linguagem como "a de prototipar"
> convidava exatamente o atalho que a skill existe para matar — e, na prática, o protótipo que dá
> certo **nunca é reescrito**: ele vira produção com o piso faltando. Ruby entra aqui pelo que
> entrega **com** o piso (Rails para produto, scripts, automação), como qualquer outra do rol.
- **front** → **Node** (Next/Astro), sempre.

> Se **dois** encaixam, aplique o desempate de `schematize-engineering → references/linguagens.md` e registre o porquê no ADR. Não se
> mistura linguagem **dentro do mesmo bounded context** sem ADR.

## 4. O ADR inicial de linguagem (obrigatório no dia 0)

O `/scaffold-new` grava um **ADR inicial** por serviço em
`<projeto>_archive/decisoes/ADR-NNNN-linguagem-<ctx>.md`, no formato da casa:

```
# ADR-0001 — Linguagem do <projeto>_<ctx>

Status: accepted
Data: <YYYY-MM-DD>

## Contexto
<que serviço é, que problema resolve, restrições (perf, segurança, time, ecossistema)>

## Decisão
<Linguagem X> para <projeto>_<ctx>, do rol sancionado.

## Fit / justificativa
<por que X encaixa: ex. "auth manipula input hostil e chave de assinatura → Rust (errar é caro)">

## Alternativas descartadas
<Go/Elixir/... e por que não>

## Consequências
<skill irmã que rege (schematize-<lang>), sufixo de repo, o que o piso exige nessa linguagem>
```

Regra: **um ADR por serviço**, no dia 0. Serviço sem ADR de linguagem = decisão por gosto = veto
do `/scaffold-check`. O ADR `proposed` que nunca vira `accepted`/`rejected` é órfão (a
`schematize-audit` pega isso).

## 5. O piso NÃO muda com a linguagem

A escolha muda o **como**, nunca o **o quê**. Valem **integralmente**, em qualquer linguagem: os
pisos de segurança, IAM (app separada), testes+pentest, arquitetura/DDD, ops (promoção/seed/
isolamento), observabilidade, DoD, archive/índice, overdev (`references/piso.md`). A skill irmã
especializa a implementação; ela **não** relaxa o piso.
