---
description: schematize-scaffold — cria ou mescla o CLAUDE.md sempre-on do scaffold na raiz do repo (não sobrescreve blocos de outras skills)
---

Instale/atualize a regra **sempre-on** de projeto-novo-da-casa na raiz do repositório.

1. Pegue `assets/CLAUDE.md` da skill `schematize-scaffold` (projeto ou `~/.claude/skills/...`).
2. Se **não existe** `CLAUDE.md` na raiz: crie com esse conteúdo.
3. Se **já existe** (de outra skill — engineering/go/rust/web/audit/...): **mescle** — adicione a
   seção de Scaffold (projeto novo da casa) **sem sobrescrever** os blocos das outras skills. Em
   repo multi-skill, cada CLAUDE convive; o piso do scaffold é aditivo.
4. Se houver customização local, salve `./CLAUDE.md.bak` e reaplique por cima.
5. Confirme a versão aplicada e destaque o **piso**: o piso é dia 0 (nada de IAM/ops pra depois);
   auth é app separada (OIDC) desde o primeiro commit; linguagem por fit + ADR; archive/índice e
   DoD desde o começo.
