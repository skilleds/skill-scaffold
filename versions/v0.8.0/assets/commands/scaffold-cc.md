---
description: Context Compact — gera handoff (context.md + checklist.md) no <projeto>_archive e compacta
---

Antes de compactar, **arquive o handoff** (não perca o estado do scaffold/bootstrap):

1. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-context.md` — estado: topologia decidida
   (bounded contexts + linguagem/ADR por serviço), quais repos já foram scaffoldados
   (`auth`/`authfront`/`front`/contextos/`ops`), que peças do piso já estão de pé vs faltando,
   onde parou.
2. `<projeto>_archive/context/<YYYY-MM-DD-HH-MM-SS>-checklist.md` — **FEITO vs EM ABERTO** (o
   checklist de bootstrap de `references/bootstrap.md`: peças do piso montadas vs pendentes).
   Registre também `ultimo_handoff` em `<projeto>_archive/.ritmo.json` (piso 26: handoff a cada 6 h)
   e **commit + push** do archive (piso 22: `HEAD == origin`).
3. Só então rode `/compact` (foco na tarefa corrente).
