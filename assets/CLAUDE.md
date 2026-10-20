# CLAUDE.md — Projeto Novo da Casa / Scaffold (sempre on)

> Copie para a **raiz do repositório** e ajuste `<project>`. Fica pinado no contexto de toda
> tarefa e garante o piso mesmo quando a skill `schematize-scaffold` não dispara sozinha. Em repo
> multi-skill, use **junto** com os `CLAUDE.md` das skills de engenharia (rode `/scaffold-claude`
> que mescla, sem sobrescrever os outros blocos).

## Regra mestre

Um projeto da casa **nasce com o piso inteiro no dia 0** — não com um `main` que responde 200 e
"segurança/ops depois". A skill `schematize-scaffold` rege *como* um projeto novo é instanciado
(estrutura canônica + piso de fábrica) e como se **audita** (`/scaffold-check`) se um projeto
existente o tem. Em conflito entre "começa simples, coloca depois" e este piso, **o piso vence**.
Consulte o reference antes de agir — não trabalhe de memória.

## Pisos inegociáveis (VETADO — sem exceção)

1. **O piso é DIA 0, não sprint futuro.** IAM (app separada), ops (isolamento por app), CI gated,
   testes+pentest, observabilidade, DoD, archive/índice e overdev **nascem com o projeto**.
   "Depois" é "nunca"; "sem segurança pra ir rápido" é dívida disfarçada. Projeto sem o piso é
   protótipo — e protótipo exige **ADR com data de virada**, não um encolher de ombros.
2. **Auth é APP SEPARADA desde o primeiro commit.** `<project>_auth_<lang>` (IdP) **+**
   `<project>_authfront`, repo/deploy/user/systemd próprios, em `auth.<domain>`; o app principal
   **delega por OIDC/OAuth2.1 + PKCE**. VETADO apensar login ao escopo principal "por enquanto".
   Baseline: ID≠email, ≥2 fatores (senha + Email OTP já conta; passkey núcleo), ReBAC
   multi-tenant, deny-by-default, chave só no auth + JWKS. **IAM é prioridade 0.**
3. **Um repo = um bounded context, dentro do workspace.** Padrão `<project>_<ctx>_<lang>`, repos
   **irmãos dentro da pasta do projeto** (nunca soltos no root, nunca `cd ..`). Front separado do
   backend. Nada de monólito que acopla contextos sem ADR de plano **e data** de quebra.
4. **`<project>_ops` desde o dia 0 — control plane.** Bootstrap + instalação paralela (`nproc`),
   deploy destrutivo por seed (`/<app>/.env`), isolamento por app (user Linux + systemd hardened),
   fluxo de promoção (dev→teste→git→hml→prd). **100%** das operações passam por ele; nada de mão
   no servidor.
5. **Linguagem por fit + ADR inicial.** Backend novo do rol (Go/Rust/Elixir/C#/Zig/Ruby),
   escolhido por encaixe e **registrado em ADR** no dia 0. Front é Node (Next/Astro). O piso é o
   mesmo em toda linguagem — ela muda o "como", não o "o quê".
6. **Archive e índice desde o primeiro commit.** `<project>_archive/` existe no dia 0; toda
   entrega gera o `.md` de archive; `MAPA.md`/índice (§39) mora no archive; **root limpo**.
7. **Overdev + DoD como gate.** O projeto nasce com `/eng-overdev` disponível e a DoD (§35) como
   gate de entrega. O bootstrap só fecha quando o piso **inteiro** está de pé, **provado** (não
   auto-declarado).

8. **Efeito externo nasce em SINK — default de fábrica.** O `.env.example`/seed gerado já traz
   **`APP_ENV`**, **`MAIL_PROVIDER=sink`**, **`TEST_MAIL_DOMAIN=test.<domain>`** (domínio em **rota
   nula**: null MX + SPF `-all` + DMARC `p=reject`) e **`MAIL_MAX_PER_RUN=50`**; o
   **`docker-compose` de dev sobe o Mailpit** (`:8025` UI/API pro teste ler a caixa, `:1025` SMTP);
   o **guard mora DENTRO do provider** (destinatário fora do domínio de teste + `APP_ENV != prd` →
   **erro**, fail-closed) e vem com o **teste que vê a recusa**; fixture/seed/persona só emitem
   `<papel>+<run-id>-<n>@test.<domain>`. **VETADO** provedor real por default fora de `prd`, chave
   de prd em `.env` de não-prd, envio sem cap e `@gmail.com`/caixa real em template. O
   `/scaffold-check` confere isso como 9ª peça (veto duro se o projeto envia). Normativa:
   `schematize-engineering` → `references/efeitos-externos.md`.

## Como se faz aqui

- **Projeto novo (`/scaffold-new`):** decide topologia + linguagem/ADR (Fase 0), cria o archive,
  scaffolda o **auth primeiro** (app separada + OIDC), depois contextos + front, o `ops`, amarra
  CI gated + DoD + observabilidade, liga o overdev e fecha com `/scaffold-check` verde.
- **Projeto existente (`/scaffold-check`):** audita as 11 peças do piso **com prova de hoje**,
  aponta `missing`/`partial` com origem, gera o **checklist de saneamento** (candidato a
  `/eng-overdev`) e **trava** se faltar peça do dia 0 (IAM/segurança/ops/archive). Relatório em
  `<project>_archive/scaffold/`.

9. **IAM com passkey na fase 0 e matriz de acesso por rota desde o primeiro endpoint.** Passkey/WebAuthn é o método padrão (piso 21): registro+asserção reais e2e antes de qualquer feature, com testes de challenge reutilizado, origin/rpId errado e credencial revogada rejeitados; a implementação mora no IAM da casa (`schematize-iam`). Toda rota nasce com teste de matriz de acesso (piso 20): 4 personas, status e corpo, deny-by-default, allowlist de públicas com dono, gate M == N no CI (`schematize-qa`). `/scaffold-check` confere como 10ª e 11ª peças (`scripts/check-day0-auth.sh`).

10. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado --> O `CLAUDE.md` que o scaffold gera para o projeto novo inclui este piso.

## Relação com as outras skills

- **schematize-engineering** — a base que este scaffold materializa (arquitetura §2, IAM, ops.md,
  DoD §35, archive §28, índice §39, overdev). O scaffold dá o passo-a-passo de instanciá-la.
- **schematize-audit** — o par: o `/scaffold-check` audita o **piso**; o audit audita se os
  **checklists criados** foram sanados.
- **schematize-<lang>** (go/rust/elixir/csharp/zig/ruby) — a implementação idiomática de cada peça
  (`/<prefixo>-iam`, `/<prefixo>-ops`). **schematize-web** — os fronts. **schematize-pentest** — o *(o prefixo NÃO se deriva do nome da skill — ver `schematize-engineering → references/linguagens.md`; em C# é `/cs-iam`.)*
  oráculo que ataca o IAM/authz montado.

## Gestão de contexto (sessões longas)

Ao se aproximar do teto de contexto: **PARE e** gere o handoff em `<project>_archive/context/`
(topologia + peças do piso FEITO vs EM ABERTO) **antes** de compactar (`/scaffold-cc`).
