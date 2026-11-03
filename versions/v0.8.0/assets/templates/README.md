# Templates do dia 0

> **Por que estes arquivos existem.** A `schematize-scaffold` promete um *"blueprint EXECUTÁVEL"*
> — e entregava **prosa**: de 19 artefatos citados no bootstrap, só 2 tinham forma. A diferença é
> concreta: um blueprint em prosa faz cada projeto inventar o próprio `.gitignore`, e é assim que o
> `.env` escapa uma vez. Achado da vistoria de 2026-08-21.

| Template | Copie para | O que ele resolve |
|---|---|---|
| `gitignore.tpl` | `.gitignore` na raiz de **cada** repo | segredo fora do git **antes do 1º commit** (segredo commitado uma vez está vazado para sempre — rotacione, não "remova o commit"), `.schematize/` fora, derivados fora |
| `env.example.tpl` | `.env.example` na raiz | o **contrato** de config: toda variável que a app lê está listada, com exemplo seguro. Inclui as **4 camadas** do piso de efeito externo (`MAIL_PROVIDER`, `MAIL_SINK_URL`, `TEST_MAIL_DOMAIN`, `MAIL_MAX_PER_RUN`, mais `MAIL_FROM`) já preenchidas |
| `ci.yml.tpl` | `.github/workflows/ci.yml` de **cada** repo de código | CI do **piso 27**: `workflow_dispatch` + `push: tags [hml-*, v*]`, `concurrency` com `cancel-in-progress`, `paths-ignore`; **sem** `pull_request`/push em branch. O gate por commit é local (`tools/ci.sh`) |
| `resilience.yml.tpl` | raiz de **cada** serviço | piso 28: dependências declaradas (matriz M == N) e os 7 testes de resiliência nascendo vermelhos |
| `ritmo.json.tpl` | `<projeto>_archive/.ritmo.json` | piso 26: carimbos `ultimo_relatorio`/`ultimo_handoff` (ISO-8601) que o `check-ritmo.sh` lê |
| `maquinas.yml.tpl` | `<projeto>_ops/maquinas.yml` | piso 29 (opcional): inventário da máquina dev/hml de build/teste (`env` ∈ {dev,hml}, `papel: build-teste`) |

**Os demais artefatos do bootstrap** (Dockerfile, compose, steps de build por linguagem, healthcheck, systemd unit) **não são
templates desta skill de propósito**: eles mudam por linguagem e por infra, e já têm dono —
`assets/ci/` da skill da linguagem (**só os passos de build/teste**: o **gatilho** do workflow é sempre o do `ci.yml.tpl`, piso 27; template de linguagem com `pull_request`/`on: push` em branch é defeito dele, não copie o `on:`), e a `schematize-infra` para container/unit/deploy. Duplicá-los
aqui criaria a nona cópia divergente, que é exatamente a Classe C da vistoria.

**O que fica sendo prosa, e por quê:** as decisões (qual linguagem, quais bounded contexts, quais
repos) — porque são **decisão com ADR**, não arquivo para copiar.
