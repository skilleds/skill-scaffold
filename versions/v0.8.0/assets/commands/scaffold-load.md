---
description: schematize-scaffold — carrega à força TODO o corpo normativo (estrutura, piso, linguagem, bootstrap, check) e passa a aplicá-lo
---

Carregue **à força** e passe a aplicar **integralmente** o Blueprint de Projeto Novo da Casa
(skill `schematize-scaffold`) neste projeto. A partir de agora, nesta sessão, isto **não é
opcional**.

1. **Leia agora, na íntegra, TODOS os references** — não trabalhe de memória. Caminho:
   `.claude/skills/schematize-scaffold/references/*.md` (projeto) ou
   `~/.claude/skills/schematize-scaffold/references/*.md` (global):
   - `estrutura.md` — a **estrutura canônica**: workspace/contenção, repos por contexto
     (`<projeto>_<ctx>_<lang>`), **auth como app separada** (`<projeto>_auth_<lang>` +
     `<projeto>_authfront`) + delegação OIDC, front separado, `<projeto>_ops`, `<projeto>_archive`,
     independência de runtime.
   - `piso.md` — o **piso de fábrica** do dia 0: segurança, testes+pentest, **IAM baseline 2FA**,
     ops/isolamento por app, observabilidade, CI com deploy gated, **DoD (§35)**, archive/índice
     (§39), overdev — e a regra "dia 0, não sprint futuro".
   - `linguagem.md` — a **escolha de linguagem** por fit (rol Go/Rust/Elixir/C#/Zig/Ruby; front
     Node) e o **ADR inicial** obrigatório por serviço.
   - `bootstrap.md` — o **passo-a-passo** de criar o projeto novo (Fase 0 decidir → archive →
     auth primeiro → contextos+front → ops → CI/DoD/observabilidade → overdev), com o checklist.
   - `check.md` — o **scaffold-check**: auditar um projeto existente contra o piso, o que conta
     como prova de cada peça, o checklist de saneamento e o gate.
   - `gui.md` — **como a skill vira botão na GUI**: o `gui.json` na raiz da skill (ao lado do
     `SKILL.md`), lido pela aba do projeto; é o mecanismo geral do qual Q.A. e Pentest são
     instâncias. Projeto novo que ganha comando próprio nasce plugável na GUI sem tocar no app.

2. **Confirme ao usuário** que leu (1 linha por arquivo).

3. Deste ponto, aplique como regra inegociável: **o piso é dia 0** (nada de IAM/ops "pra depois"),
   **auth é app separada** desde o primeiro commit (OIDC/PKCE), **um repo = um bounded context**
   no padrão `<projeto>_<ctx>_<lang>` dentro do workspace, **linguagem por fit + ADR inicial**,
   **`<projeto>_ops` como control plane** (promoção/seed/isolamento/`nproc`), **archive/índice
   desde o primeiro commit**, e **overdev + DoD como gate** (fecha provado, não auto-declarado).

4. **Atualize o `CLAUDE.md` da raiz** com `assets/CLAUDE.md` da skill (mescla se já houver de
   outra skill) — é o `/scaffold-claude`.
