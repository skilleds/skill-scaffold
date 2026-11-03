# schematize-scaffold

> O **scaffolder da casa** — o blueprint **executável** de "projeto novo da casa", o que dá lastro
> pelo comando `/scaffold-new`. Um projeto que **já nasce** com o piso do dia 0: repos por
> contexto (`<projeto>_<ctx>_<lang>`), **IAM como app separada** (`<projeto>_auth_<lang>` +
> `<projeto>_authfront`, delegação OIDC), front separado, `<projeto>_ops` com isolamento por app,
> CI com deploy gated, testes/pentest, DoD, archive/índice e overdev — com a **linguagem escolhida
> por fit + ADR inicial**. Nada de projeto "sem IAM/sem ops pra depois": **o piso é dia 0**.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**. Disciplina **agnóstica de linguagem** que **materializa**
a `schematize-engineering` (a base: arquitetura/IAM/ops/DoD/archive/índice/overdev) num passo-a-passo
de criar projeto do zero, e pareia com a `schematize-audit` (o `scaffold-check` audita o **piso**;
o audit audita se os **checklists criados** foram sanados).

## Instalar

### Pelo app schematize (recomendado)

```bash
schematize install scaffold      # requer o CLI schematize instalado
```

### Última versão (a partir de um clone)

```bash
git clone https://github.com/schematizeme/skill-scaffold.git
cd skill-scaffold && ./install.sh            # instala no projeto atual
# ./install.sh /caminho/do/projeto             # ou aponte para outro projeto
```

Ou baixe o `.zip` da última release e descompacte em `.claude/skills/`:

```bash
curl -L -o skill-scaffold.zip \
  https://github.com/schematizeme/skill-scaffold/releases/latest/download/skill-scaffold.zip
unzip skill-scaffold.zip -d .claude/skills/
```

## O que tem dentro

- **SKILL.md** — o contrato: 10 pisos inegociáveis (o piso é dia 0; auth app separada desde o 1º
  commit; um repo = um bounded context no workspace; `<projeto>_ops` desde o dia 0; linguagem por
  fit + ADR inicial; archive/índice desde o 1º commit; overdev + DoD como gate; IAM com passkey na fase 0 e matriz de acesso por rota) + mapa de references.
- **references/** — `estrutura` (a topologia canônica), `piso` (o piso de fábrica do dia 0),
  `linguagem` (rol + fit + ADR inicial), `bootstrap` (o passo-a-passo de criar), `check` (auditar o
  piso de um projeto existente), `gui` (como a skill vira botão na GUI, via `gui.json`).
- **assets/commands/** — `/scaffold-help`, `/scaffold-new` (criar projeto novo), `/scaffold-check`
  (auditar o piso), `/scaffold-load`, `/scaffold-claude`, `/scaffold-cc`, `/scaffold-handoff`.
- **assets/CLAUDE.md** — regra sempre-on: o piso é dia 0; auth app separada (OIDC); ops/archive/DoD
  desde o começo.

## Regra de ouro

**O piso é dia 0, não sprint futuro.** Um projeto da casa nasce com IAM (app separada), ops
(isolamento por app), CI gated, testes/pentest, observabilidade, DoD, archive e overdev — a feature
vem **em cima** do piso, não antes dele. "Coloco segurança depois" é "coloco nunca". Auth nasce
separado (`<projeto>_auth_<lang>` + `authfront`, delegação OIDC) desde o primeiro commit; a
linguagem sai do **rol sancionado por fit + ADR**.

## Relação com as outras skills

- **schematize-engineering** — a base que este scaffold materializa (arquitetura §2, IAM, ops.md,
  DoD §35, archive §28, índice §39, overdev); o scaffold dá o passo-a-passo de instanciá-la.
- **schematize-audit** — o par: o `/scaffold-check` audita o **piso**; o audit audita se os
  **checklists criados** foram sanados.
- **schematize-\<lang\>** (go/rust/elixir/csharp/zig/ruby) — a implementação idiomática de cada peça
  (`/<prefixo>-iam`, `/<prefixo>-ops`). **schematize-web** — os fronts. **schematize-pentest** — o oráculo *(o prefixo NÃO se deriva do nome da skill — a tabela de `references/linguagem.md` tem a coluna; em C# é `/cs-iam`.)*
  que ataca o IAM/authz montado.

## Co-autoria / patrocínio

Co-autoria / patrocínio: Lucassa — https://lucassa.me

MIT.
