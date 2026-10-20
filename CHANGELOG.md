# Changelog — schematize-scaffold

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).
## [0.7.0] — 2026-10-20
### Adicionado
- Piso do dia 0 exige passkey na fase 0 e matriz de acesso por rota com gate no CI desde o primeiro endpoint.
- Script `scripts/check-day0-auth.sh` (+ teste) e check com 11 peças.



## [0.6.0] — 2026-10-14
Saneamento pelo gate novo da skill-dev; sem mudança de piso próprio.

### Alterado
- Blocos herdados `engineering/precedencia` (variante `dominio`) e `engineering/orquestracao` inseridos onde faltavam e sincronizados (`tools/sync-herdados.mjs`).
- Description reduzida para ≤190 caracteres (orçamento do catálogo, 45 skills).

## [0.5.4] — 2026-10-14
Ressincronização dos blocos herdados com a engineering v0.27.0; sem mudança de piso próprio.

### Alterado
- Description reduzida (≤235 chars) para caber no orçamento de listagem de skills (soma ≤8300); mesmo território, fronteiras com as irmãs preservadas.
- Blocos herdados ressincronizados com a `schematize-engineering` v0.27.0 (`tools/sync-herdados.mjs`): orquestração com a regra de imagem (nunca pelo Claude; detecta Codex/Gemini e pergunta ao usuário qual usar, Codex como sugestão) e `schematize overdev delegar` (comando do app) no lugar do falso nome de skill `schematize-overdev`.

## [0.5.3] — 2026-10-14

### Corrigido
- Frase quebrada em "Relação com as outras skills" (prefixo de comando) reescrita; nota histórica sobre `schematize new` reduzida a uma linha (o histórico mora aqui).
- ADR inicial de linguagem agora em `<projeto>_archive/decisoes/ADR-NNNN-linguagem-<ctx>.md` (antes "archive ou `assets/ADR.md`", caminho que não existe).
- `linguagem.md`: a tabela do rol (com prefixo de comando) é ponteiro para `schematize-engineering → references/linguagens.md`; removido o "default pragmático Go" local (desempate só na base).
- `bootstrap.md` aponta para a planta do archive da `schematize-archive` em vez de listar 7 pastas.
- Bloco de efeito externo no SKILL.md reduzido a resumo + ponteiro para `references/efeitos-externos.md` da engineering; bloco de orquestração (herdado) mantido.
- Removidas citações a ADR-0005/0006 (outro repo): cita-se a regra.
- `scaffold-check.md` e `piso.md` usam o caminho instalado do `check-external-effects.sh`.
- Description reduzida a <=350 caracteres.
- **Description** reduzida (~270 chars) para caber no orçamento de listagem (soma das 31 skills ≤ 8500; o Claude Code corta a listagem acima disso).

### Alterado
- `scripts/check-external-effects{,.test}.sh` viram arquivos herdados da engineering (cabeçalho "herdado de schematize-engineering — não edite aqui"); conteúdo inalterado.

## [0.5.2] — 2026-09-30
O piso de orquestração passa a ser **herdado** da base em vez de copiado à mão: uma mudança na engineering não exige mais editar 38 arquivos.

### Alterado
- Piso "Orquestrador não desenvolve; subagent barato executa" em `assets/CLAUDE.md` e `SKILL.md` agora é um bloco `<!-- herdado:engineering/orquestracao:… -->`, sincronizado de `schematize-engineering/assets/herdados/orquestracao.md` por `tools/sync-herdados.mjs` (checado no CI). Redação normalizada; conteúdo inalterado.

### Mantido (piso inalterado)
- Sonnet por default, escada até opus, sem frota ociosa (engineering `references/orquestracao.md` §9/§9.6).

## [0.5.1] — 2026-09-30
Pedido do dono: agents idle poluem a tela e seguram recurso.

### Adicionado
- Piso de orquestração ganha a regra de frota ociosa (idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata); detalhe na `schematize-engineering` §9.6.

## [0.5.0] — 2026-09-30
Pedido do dono, por **custo**: o agent principal não desenvolve — planeja e despacha; subagents
executam em `sonnet` por padrão e `opus` só após falha. Regra canônica em `schematize-engineering`
→ `references/orquestracao.md` §9.

### Adicionado
- **Piso herdado "Orquestrador não desenvolve; subagent barato executa"** em `SKILL.md`,
  `assets/CLAUDE.md` e `references/piso.md` §8.1: todo projeto novo (e o `CLAUDE.md` que o scaffold
  gera) nasce com a orquestração barata.

### Mantido (piso inalterado)
- Piso do dia 0, auth app separada, ops, DoD/overdev, archive e o efeito externo em sink de
  fábrica; a tabela-resumo do `/scaffold-check` (9 peças) não muda.

## [0.4.0] — 2026-08-21
Segunda leva do saneamento: determinismo, banco no dia 0, archive canônico e o prefixo de comando.

### Adicionado
- **`bootstrap.md` §0 — Determinismo.** *Se o blueprint admite interpretação, cada execução produz uma árvore distinta — e o `/scaffold-check` passa a auditar contra um alvo móvel.* Datas em **ISO/UTC vindas do ambiente**, convenção de nome por tipo de artefato, **default de linguagem sem "costuma"** (auth → Rust; empate → Go; front → Node), ordem dos passos fixa, e **nada de perguntar no meio** (vira `[REVISAR: negócio]` + `- [H ]`). Com o critério de prova: duas execuções, a mesma árvore.
- **`piso.md` §4.1 — Banco de dados no dia 0**: um banco por serviço, schema desenhado (ULID/UUIDv7, PII fora do índice, `numeric` para dinheiro, `timestamptz`), **migração `0001` versionada e reversível**, compose de dev com o **banco real**, credencial pelo seeder, app sem DDL em prd, e restore ensaiado. *Banco é onde o erro de dia 0 fica mais caro: schema errado se corrige com migração em produção, não com refatoração.*

### Corrigido
- **`/<slug>-iam` quebrava em C#.** A tabela de `linguagem.md` ganhou a coluna **"Prefixo de comando"** (conferida contra o `assets/commands/` de cada skill): em C# é **`/cs-iam`**, não `/csharp-iam`. As remissões passaram a `/<prefixo>-iam` em todos os arquivos.
- **Archive: planta canônica + repo git PRIVADO.** O §7 deixou de descrever um layout próprio e passou a apontar a `schematize-archive` (ADR-0005/0006), com o piso que faltava — *privado porque guarda transcript; próprio porque é o que faz o rastro sobreviver à perda da máquina: archive que só existe no seu disco não é criticidade 0, é uma pasta*.

## [0.3.0] — 2026-08-21
Saneamento do catálogo conforme a vistoria de 2026-08-21.

### Corrigido
- **A promessa do `schematize new` saiu**: ✔ verificado — o subcomando **não existe** no binário (`unrecognized subcommand`). O blueprint é executado por **`/scaffold-new`** e auditado por `/scaffold-check`; ficou registrado que, se um dia existir, o lastro é o `SKILL.md`. **Fronteira:** o CLI vive noutro projeto.
- **Peça 9 (efeito externo) no `/scaffold-check`**, que enumerava só 1..8 — regressão do próprio v0.2.0 —, agora com as **quatro provas** separadas e o como provar hoje.
- **Overdev coerente entre as três fontes**: **veto em projeto novo** (é peça do dia 0), **achado de saneamento com prazo em projeto existente** (ali é mudança de modo de trabalho, não defeito de segurança que se conserta em minutos). O que não pode é sumir do relatório — que era o efeito de chamá-lo de "só sinal".
- **"Prototipagem rápida" saiu do fit de Ruby**: nesta skill protótipo exige **ADR com data de virada**, e oferecer uma linguagem como "a de prototipar" convidava o atalho que a skill existe para matar — *o protótipo que dá certo nunca é reescrito: ele vira produção com o piso faltando*.

### Adicionado
- **`assets/templates/`** — `gitignore.tpl` (segredo fora do git **antes do 1º commit**; *segredo commitado uma vez está vazado para sempre: a ação é rotacionar*) e `env.example.tpl` (o **contrato** de config, com as 4 camadas do piso de efeito externo preenchidas), com um README dizendo **o que não vira template e por quê**.
- `references/gui.md` deixou de ser órfão: entrou no mapa do `SKILL.md`, no `/scaffold-load` e no README.

## [0.2.0] — 2026-08-20

Propagação do piso **"efeito externo NUNCA sai de não-produção"** no recorte de **SCAFFOLD** — o
ponto em que o piso deixa de depender de alguém lembrar e vira **default de fábrica**: projeto
novo **nasce** com o envio em sink. Normativa: `schematize-engineering` →
`references/efeitos-externos.md` (origem: um laço de teste disparou **>5.000 e-mails reais** e
queimou a reputação de IP/domínio, derrubando o **OTP de login** de produção).

### Adicionado
- **SKILL.md** — piso inegociável **8** ("Projeto novo NASCE com o efeito externo em SINK"):
  `.env.example`/seed com `APP_ENV` + `MAIL_PROVIDER=sink` + `TEST_MAIL_DOMAIN` + `MAIL_MAX_PER_RUN`,
  Mailpit no compose, guard dentro do provider com teste da recusa, fixtures só no domínio de
  teste; menção ao piso na `description` do frontmatter.
- **references/piso.md** §9 — "Efeito externo: SINK por default — o piso vira default de FÁBRICA":
  o **`.env.example`/seed gerado** (com o bloco pronto e o motivo de cada chave), o
  **`docker-compose` de dev com Mailpit** pinado por digest (`:8025` UI/API pro teste **ler** a
  caixa, `:1025` SMTP), o guard dentro do provider + o teste que vê o vermelho, fixtures na forma
  `<papel>+<run-id>-<n>@test.<domain>` (com a lista de vetados), o gate
  `check-external-effects.sh` no CI do dia 0 e o item de **DNS em rota nula** aberto para a
  `schematize-infra`.
- **references/bootstrap.md** — passo **18** da Fase 5 (sink de fábrica) e **2 linhas novas no
  checklist de bootstrap** (config+compose+guard+fixtures+gate; domínio de teste provado por `dig`).
- **references/check.md** — **9ª peça** do check com prova de presença e bandeiras vermelhas
  (provedor real por default fora de prd, chave de prd em não-prd, envio sem cap, caixa real em
  fixture, guard no chamador), **3 itens novos** no checklist de saneamento e **veto duro** no gate
  para projeto que envia.
- **assets/CLAUDE.md** — piso sempre-on **8** com as chaves de fábrica, o Mailpit e os vetos.

### Mudado
- **references/piso.md** — a tabela-resumo do piso passa de §9 para **§10** e ganha a **9ª peça**
  ("Efeito externo (sink de fábrica)"); referências em `check.md` e `assets/CLAUDE.md` atualizadas
  de "8 peças" para "9 peças".

## [0.1.0] — 2026-08-15

Primeira versão da skill de **scaffold** da casa — o blueprint executável de "projeto novo da
casa", lastro do futuro comando `schematize new <projeto>`. Materializa o piso descrito na
`schematize-engineering` (arquitetura §2, IAM, ops, DoD §35, archive §28, índice §39, overdev) num
passo-a-passo de criar projeto do zero, e traz o `scaffold-check` que audita esse piso num projeto
existente (par da `schematize-audit`).

### Adicionado
- **SKILL.md** com 7 pisos inegociáveis (o piso é dia 0; auth app separada desde o 1º commit; um
  repo = um bounded context no workspace; `<projeto>_ops` desde o dia 0; linguagem por fit + ADR
  inicial; archive/índice desde o 1º commit; overdev + DoD como gate) + mapa de references +
  relação com engineering/audit/linguagem/web/pentest.
- **references/**:
  - `estrutura.md` — a estrutura canônica: workspace/contenção, repos por contexto
    (`<projeto>_<ctx>_<lang>`), **auth como app separada** (`<projeto>_auth_<lang>` +
    `<projeto>_authfront`) + delegação OIDC, front separado, `<projeto>_ops`, `<projeto>_archive`,
    independência de runtime, root limpo.
  - `piso.md` — o piso de fábrica do dia 0: segurança, testes+pentest, IAM baseline 2FA,
    ops/isolamento por app + CI gated, observabilidade, DoD (§35), archive/índice (§39), overdev;
    tabela-resumo das 8 peças que o check procura.
  - `linguagem.md` — rol sancionado (Go/Rust/Elixir/C#/Zig/Ruby; front Node), guia de fit, o **ADR
    inicial** obrigatório por serviço, e "o piso não muda com a linguagem".
  - `bootstrap.md` — o passo-a-passo (Fase 0 decidir → archive → auth primeiro → contextos+front →
    ops → CI/DoD/observabilidade → overdev) com o checklist de bootstrap derivável pro overdev.
  - `check.md` — o scaffold-check: as 8 peças com prova de presença, como conduzir (enumerar →
    provar → classificar), o checklist de saneamento, o gate (IAM/segurança = prioridade 0) e
    onde gravar.
- **assets/commands/**: `/scaffold-help`, `/scaffold-new` (criar projeto novo), `/scaffold-check`
  (auditar o piso), `/scaffold-load`, `/scaffold-claude`, `/scaffold-cc`, `/scaffold-handoff`.
- **assets/CLAUDE.md** — regra sempre-on: o piso é dia 0; auth app separada (OIDC); um repo = um
  bounded context; ops/archive/DoD desde o começo.
