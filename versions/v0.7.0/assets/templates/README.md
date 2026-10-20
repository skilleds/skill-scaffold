# Templates do dia 0

> **Por que estes arquivos existem.** A `schematize-scaffold` promete um *"blueprint EXECUTÁVEL"*
> — e entregava **prosa**: de 19 artefatos citados no bootstrap, só 2 tinham forma. A diferença é
> concreta: um blueprint em prosa faz cada projeto inventar o próprio `.gitignore`, e é assim que o
> `.env` escapa uma vez. Achado da vistoria de 2026-08-21.

| Template | Copie para | O que ele resolve |
|---|---|---|
| `gitignore.tpl` | `.gitignore` na raiz de **cada** repo | segredo fora do git **antes do 1º commit** (segredo commitado uma vez está vazado para sempre — rotacione, não "remova o commit"), `.schematize/` fora, derivados fora |
| `env.example.tpl` | `.env.example` na raiz | o **contrato** de config: toda variável que a app lê está listada, com exemplo seguro. Inclui as **4 camadas** do piso de efeito externo (ADR-0004) já preenchidas |

**Os demais artefatos do bootstrap** (Dockerfile, compose, CI, healthcheck, systemd unit) **não são
templates desta skill de propósito**: eles mudam por linguagem e por infra, e já têm dono —
`assets/ci/` da skill da linguagem, e a `schematize-infra` para container/unit/deploy. Duplicá-los
aqui criaria a nona cópia divergente, que é exatamente a Classe C da vistoria.

**O que fica sendo prosa, e por quê:** as decisões (qual linguagem, quais bounded contexts, quais
repos) — porque são **decisão com ADR**, não arquivo para copiar.
