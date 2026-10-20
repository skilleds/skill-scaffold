---
description: Gera o handoff de contexto (context.md + checklist.md) no archive, SEM compactar
---

Gere o handoff do scaffold/bootstrap **sem** compactar — pra fim de sessão ou troca de tarefa:

1. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-context.md` — topologia decidida (bounded
   contexts + linguagem/ADR por serviço), repos já scaffoldados vs pendentes, peças do piso de pé
   vs faltando, decisões, onde parou.
2. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-checklist.md` — **FEITO vs EM ABERTO** (o
   checklist de bootstrap de `references/bootstrap.md`).

Não rode `/compact` — só arquiva.
