---
description: schematize-scaffold — lista todos os comandos disponíveis e o que cada um faz
---

Liste os comandos do **schematize-scaffold** instalados (`/scaffold-*`), com 1 linha cada:

- `/scaffold-help` — esta lista.
- `/scaffold-new` — o passo-a-passo de **criar projeto novo** já com o piso do dia 0: fixa a topologia (bounded contexts), escolhe linguagem por fit + **ADR inicial**, scaffolda `<projeto>_auth_<lang>` + `authfront` (IAM app-separada, OIDC) + `front` + contextos do produto + `<projeto>_ops` (control plane), amarra CI gated, observabilidade, DoD, archive/índice e liga o overdev.
- `/scaffold-check` — roda contra um **projeto existente** e aponta **o que falta do piso** (IAM app-separada? ops/isolamento? CI gated? testes/pentest? DoD? archive/índice? overdev?), com prova de hoje; gera o **checklist de saneamento** (candidato a `/eng-overdev`) e **trava** se faltar peça do dia 0 (IAM/segurança/ops/archive = prioridade 0).
- `/scaffold-load` — carrega à força TODO o corpo normativo (estrutura, piso, linguagem, bootstrap, check) e passa a aplicá-lo.
- `/scaffold-claude` — cria ou mescla o `CLAUDE.md` sempre-on do scaffold na raiz do repo.
- `/scaffold-cc` — context compact: gera handoff no archive e roda `/compact`.
- `/scaffold-handoff` — gera o handoff (context.md + checklist.md) sem compactar.

Depois da lista, lembre a **regra de ouro**: *o piso é dia 0, não sprint futuro.* Nada de projeto
"sem IAM/sem ops pra depois" — **depois é nunca**. Auth nasce **app separada** (`<projeto>_auth_<lang>`
+ `authfront`, delegação OIDC) desde o primeiro commit; a escolha de linguagem sai do **rol
sancionado por fit + ADR**. Detalhe normativo em `references/` da skill `schematize-scaffold`; a
base que ele materializa (arquitetura/IAM/ops/DoD/archive/overdev) é a `schematize-engineering`; a
implementação idiomática sai da skill de linguagem escolhida. Pareia com a `schematize-audit` (o
`/scaffold-check` audita o **piso**; o audit audita se os **checklists criados** foram sanados).
