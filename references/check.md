# scaffold-check — auditar um projeto existente contra o piso do dia 0

> Nem todo projeto nasceu com o `/scaffold-new`. O `/scaffold-check` roda contra um projeto **já
> existente** e responde: **ele tem o piso da casa?** Enumera cada peça (`references/piso.md` §10),
> verifica presença **com prova**, aponta o que falta e gera o **checklist de saneamento**.
> Pareia com a `schematize-audit` (que audita se os *checklists criados* foram sanados; este
> audita se o *piso* está lá).

## 1. O que o check verifica (as 11 peças do piso)

Para cada peça, o veredito é **presente / ausente / parcial**, sempre **com prova** (não "parece
que tem"). A tabela é o `references/piso.md` §10; abaixo, o que conta como prova de cada uma.

| # | Peça | Prova de presença (o que procurar) | Bandeira vermelha (ausente/parcial) |
|---|---|---|---|
| 1 | **Segurança** | grep não acha segredo no cliente/repo; queries parametrizadas; auth server-side; validação na borda | `NEXT_PUBLIC_`/`VITE_` com segredo; SQL concatenado; authz no cliente |
| 2 | **Testes + pentest** | test kit roda **verde hoje**; existem testes de rejeição/authz | `TODO: tests`; suíte vermelha; zero teste de rejeição |
| 3 | **IAM app separada** | existe `<projeto>_auth_<lang>` **+** `<projeto>_authfront` (repos próprios); app delega por OIDC; ID≠email; ≥2 fatores; JWKS | login embutido no core; email como PK; 1 fator; chave no consumidor |
| 4 | **Ops / isolamento / CI gated** | existe `<projeto>_ops`; fluxo de promoção; seed `/<app>/.env`; user+systemd por serviço; `nproc`; CI só promove verde | deploy à mão/ssh; sem ops; serviços no mesmo user/root; CI sem gate |
| 5 | **Observabilidade** | health endpoint responde; logs estruturados/métricas/tracing versionados | "loga no stdout e pronto"; sem health |
| 6 | **DoD (§35)** | gate de PR/entrega (review + testes + archive); `/<slug>-review` existe | merge sem gate; sem DoD |
| 7 | **Archive/índice** | `<projeto>_archive/` existe e é usado; `MAPA.md`/índice (§39); root limpo | MD gerado solto no root; sem archive |
| 8 | **Overdev** | `/eng-overdev` disponível; histórico de checklist no archive | sem checklist e sem histórico. **Em projeto NOVO é veto** (peça do dia 0, `SKILL.md`/`CLAUDE.md`); **em projeto existente é achado obrigatório de saneamento**, com prazo — ver §4 |
| 9 | **Efeito externo (sink de fábrica)** | `MAIL_PROVIDER=sink` é o **default** fora de prd; `TEST_MAIL_DOMAIN` setado; `MAIL_MAX_PER_RUN` com abort; **guard dentro do provider** com **teste que vê a recusa**; Mailpit no compose de dev; nenhum `@gmail.com`/caixa real em seed/fixture/persona | provedor real ligado por default em dev/hml; chave de prd no `.env` de não-prd; envio **sem cap**; endereço de caixa real em fixture; guard "no chamador" (ou nenhum) |
| 10 | **Matriz de acesso por rota** | teste unit/componente com as 4 personas por rota do inventário (status e corpo); deny-by-default; allowlist de públicas com dono; `check-route-authz.sh` (M == N) no CI | rota sem linha na matriz; rota pública sem justificativa; sem gate; só teste e2e/manual |
| 11 | **Passkey na fase 0** | registro+asserção reais e2e no `auth.<domain>`; testes de challenge reutilizado, origin/rpId errado e credencial revogada rejeitados | `"passkey"` só como label AAL; passkey "pra depois"; só senha+OTP |

**Prova das peças 10 e 11:** `bash scripts/check-day0-auth.sh .` → exit 0 (presença dos testes e do gate; a qualidade e o vermelho visto são da `schematize-qa`).

## 2. Como conduzir (enumerar → provar → classificar)

1. **Inventário do workspace.** Liste os repos irmãos (`ls`), o que cada um é (core/auth/front/
   ops), e cruze com a topologia esperada (`references/estrutura.md` §3). Falta `auth`? falta
   `authfront`? falta `ops`? cada ausência é um achado.
2. **Prove peça por peça** (§1). **Presença exige prova de hoje** — mesma disciplina do "suspeito
   ≠ achado" da `schematize-audit`/`schematize-pentest`: "tem uma pasta `auth`" não prova IAM
   baseline; o que prova é ID≠email + ≥2 fatores + OIDC + JWKS **rodando**. Um item "meio-feito"
   é **parcial**, e parcial conta como falta no gate.
3. **Classifique** cada peça: `present` / `missing` / `partial`, com **origem** (`repo:caminho`
   ou "repo inexistente") e **o que falta**.
4. **ADRs de linguagem:** todo serviço tem ADR de linguagem `accepted`? serviço fora do rol
   (Node/PHP backend novo) sem ADR de exceção é achado (`references/linguagem.md`).

## 3. O checklist de saneamento (o que fazer com o que falta)

O check **não conserta** — ele aponta e gera o conserto. Cada peça `missing`/`partial` vira um
item de um **checklist de saneamento** (candidato a `/eng-overdev`), com o comando que resolve:

```
- [ ] IAM ausente → scaffoldar <projeto>_auth_<lang> + authfront (`/<prefixo>-iam`), migrar login embutido pra delegação OIDC *(o prefixo NÃO se deriva do nome da skill — a tabela de `references/linguagem.md` tem a coluna; em C# é `/cs-iam`.)*
- [ ] ops ausente → scaffoldar <projeto>_ops (/<slug>-ops): promoção, seed, user+systemd por app, nproc
- [ ] CI sem gate → amarrar deploy à promoção (dev→teste→git→hml→prd), só promover verde
- [ ] sem observabilidade → integrar health/logs/métricas/tracing
- [ ] sem archive → criar <projeto>_archive/, mover MD do root, gerar MAPA/índice (/eng-index)
- [ ] rota sem teste de matriz de acesso / sem gate M == N → montar a matriz (`schematize-qa`, `check-route-authz.sh`) e plugar no CI; rota pública vira allowlist com dono
- [ ] passkey ausente ou só de rótulo → implementar registro+asserção reais no IAM (`schematize-iam`), com os 5 testes da fase 0
- [ ] serviço sem ADR de linguagem → gravar ADR (fit) no dia (retroativo)
- [ ] provider de envio real por default fora de prd → inverter o default (MAIL_PROVIDER=sink), guard dentro do provider + teste da recusa, cap por execução (MAIL_MAX_PER_RUN)
- [ ] endereço de caixa real em seed/fixture/persona → reescrever pro domínio de teste em rota nula (test.<domain>) e plugar o gate no CI
- [ ] domínio de teste sem null MX/SPF/DMARC → abrir o item de DNS na IaC (schematize-infra) e provar por dig
```

> Reaproveitar de verdade: se o projeto é **legado** (Node/PHP backend), o saneamento não é
> "reescreve tudo hoje" — é **strangler-fig por módulo** (`schematize-node`) com o piso entrando
> na saída. Mas a **prioridade 0 é sempre o IAM** (app separada) e a segurança.

## 4. O gate

- **Piso são = zero peças `missing`/`partial` do dia 0** (segurança, IAM app-separada, ops/CI
  gated, testes, DoD, archive — as inegociáveis).
- **Overdev: veto em projeto novo, achado com prazo em projeto existente.** A distinção é
  deliberada e vale ser dita, porque o `SKILL.md` e o `CLAUDE.md` desta skill tratam o overdev como
  **peça inegociável** — e tratam mesmo, para quem **nasce**: um projeto criado por `/scaffold-new`
  sem overdev nasce sem o motor que fecha o próprio piso, e isso reprova. Num projeto que **já
  existe**, a ausência de histórico de checklist não é um defeito de segurança que se conserta em
  minutos: é uma mudança de modo de trabalho. Ela **entra no relatório como achado e vira item de
  saneamento com prazo** — o que não pode é sumir do relatório, que era o efeito de chamá-la de
  "só sinal".
- Observabilidade pesa junto; o **veto duro imediato** continua sendo **segurança + IAM + ops +
  archive**, e agora também **matriz de acesso por rota** (rota entregando dado sem autenticação é o bug recorrente a eliminar).
- **Efeito externo é veto duro quando o projeto envia qualquer coisa:** provedor real ligado por
  default fora de `prd`, envio sem cap ou endereço de caixa real em fixture/seed **reprovam** o
  check — o dano (reputação de domínio queimada, **OTP de login** de prd parando de chegar) não
  tem undo, e o conserto é barato **antes** do primeiro laço.
- **IAM e segurança são prioridade 0:** um projeto sem IAM app-separada **não passa** — o
  saneamento do auth vem antes de qualquer feature.
- O check é **read-mostly**: aponta e gera o saneamento; **quem conserta** é o run de saneamento
  (`/eng-overdev`), com prova. Depois, **rode o check de novo** — a peça só sai da lista quando a
  reverificação a vê presente.
- **Saída durável no archive:** o relatório do check mora em `<projeto>_archive/scaffold/<data>.md`
  (§28), nunca no root.

## 5. Quando rodar

Ao **adotar** um projeto que não nasceu com o scaffold; em **due diligence** de um repo herdado;
antes de um marco/release (o piso continua lá?); e sempre que a `schematize-audit` de histórico
apontar dívida estrutural que cheire a "nasceu sem o piso".
