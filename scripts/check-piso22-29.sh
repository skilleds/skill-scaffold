#!/usr/bin/env bash
# check-piso22-29.sh — gate das peças 12 a 18 do piso do dia 0 (pisos 22 a 29 da schematize-engineering).
# O quê: audita um WORKSPACE de projeto (pasta com os repos irmãos `<projeto>_*`, cada um com .git) e prova:
#   12 (22) git remoto: cada repo tem `git remote -v` não vazio, árvore limpa e HEAD == upstream (trava de conclusão);
#   13 (23) deploy só do git: sem scp/rsync remoto/tar|ssh/docker save|load/git bundle nos scripts de deploy/CI/ops;
#   14 (24) ops é o gate da IA: o repo `*_ops` existe e traz allowlist de operações tipadas + log de auditoria;
#   15 (26) ritmo/custos: archive com relatorios/ (>=1 .md), .ritmo.json com os dois carimbos ISO-8601 e custos/;
#   16 (27) CI remoto só antes do hml: workflows com workflow_dispatch, sem pull_request/push em branch/
#       workflow_run/merge_group/schedule, com concurrency cancel-in-progress (ci-triggers-allow.txt isenta);
#   17 (28) microserviço autônomo: cada serviço `<projeto>_<ctx>_<lang>` tem resilience.yml (e, se o gate da
#       engineering estiver à mão, os 7 testes M == N);
#   18 (29) build em dev/hml: se existe maquinas.yml, env ∈ {dev,hml} (nunca staging/prd) e papel build-teste.
# Uso: bash scripts/check-piso22-29.sh [--ativo] [--eng DIR] [dir-do-workspace]   (default: .)
#   --ativo   sessão em andamento: delega ao check-ritmo.sh da engineering (carimbo vencido reprova).
#   --eng DIR pasta scripts/ da schematize-engineering (default: procura ao lado e em .claude/skills/).
# Saída: exit 0 ok, 1 achou furo, 2 uso inválido. Não julga qualidade; prova presença/forma do que dá pra provar.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# COLETOR — soma os achados em vez de abortar no primeiro; por isso `set -uo pipefail` sem `-e`.
set -uo pipefail
ATIVO=0; ENG=""; WS="."
while [ $# -gt 0 ]; do
  case "$1" in
    --ativo) ATIVO=1 ;;
    --eng) ENG="${2:-}"; shift ;;
    -h|--help) sed -n 2,16p "$0"; exit 0 ;;
    *) WS="$1" ;;
  esac; shift
done
[ -d "$WS" ] || { echo "uso: check-piso22-29.sh [--ativo] [--eng DIR] <dir-do-workspace>" >&2; exit 2; }
FAIL=0
bad() { echo "✗ BLOQUEIA [$1] $2"; FAIL=1; }
ok()  { echo "✔ [$1] $2"; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$ENG" ]; then
  for c in "$HERE/../../skill-engineering/scripts" "$HERE/../../schematize-engineering/scripts" \
           "$WS/.claude/skills/schematize-engineering/scripts" "$HOME/.claude/skills/schematize-engineering/scripts"; do
    [ -f "$c/check-resilience.sh" ] && { ENG="$c"; break; }
  done
fi

# repos = filhos diretos com .git (o próprio WS conta se for repo)
REPOS=(); ARCH=""; OPS=""
[ -e "$WS/.git" ] && REPOS+=("$WS")
for d in "$WS"/*/; do
  d="${d%/}"; [ -e "$d/.git" ] || continue
  REPOS+=("$d")
  case "$(basename "$d")" in *_archive) ARCH="$d" ;; *_ops) OPS="$d" ;; esac
done
[ -z "$ARCH" ] && for d in "$WS"/*_archive; do [ -d "$d" ] && ARCH="$d"; done
[ -z "$OPS" ] && for d in "$WS"/*_ops; do [ -d "$d" ] && OPS="$d"; done
echo "== check-piso22-29 (ws: $WS; ${#REPOS[@]} repo(s); eng: ${ENG:-ausente}) =="
[ "${#REPOS[@]}" -gt 0 ] || bad 12 "nenhum repo git em $WS — tudo vai pro git (piso 22)"

# 12 / piso 22 — git remoto como trava de conclusão
for r in "${REPOS[@]}"; do
  n="$(basename "$(cd "$r" && pwd)")"
  if [ -z "$(git -C "$r" remote -v 2>/dev/null)" ]; then bad 12 "$n: sem remote (git remote -v vazio) — crie o repo e dê push antes de concluir"; continue; fi
  [ -z "$(git -C "$r" status --porcelain 2>/dev/null)" ] || bad 12 "$n: árvore suja — commit + push antes de concluir"
  if ! up="$(git -C "$r" rev-parse --verify -q '@{u}' 2>/dev/null)"; then bad 12 "$n: sem upstream (branch nunca empurrada)"; continue; fi
  [ "$(git -C "$r" rev-parse HEAD 2>/dev/null)" = "$up" ] && ok 12 "$n: remote ok, limpo, HEAD == origin" \
    || bad 12 "$n: HEAD != upstream (commits por empurrar ou local atrasado)"
done

# 13 / piso 23 — deploy só do git
if [ -n "$ENG" ] && [ -f "$ENG/check-deploy-git.sh" ]; then
  SKIP_GIT=1 bash "$ENG/check-deploy-git.sh" "$WS" >/dev/null 2>&1 && ok 13 "check-deploy-git (engineering): sem scp/rsync/tar|ssh" \
    || bad 13 "check-deploy-git reprovou: há envio de código fora do git (scp/rsync/tar|ssh/docker save) — rode o gate para ver as linhas"
else
  if grep -rnIE '(^|[;&|[:space:]])(scp|sftp)[[:space:]]|rsync[[:space:]][^#]*:[^[:space:]]|tar[[:space:]][^#]*\|[[:space:]]*ssh|docker[[:space:]]+(save|load)|git[[:space:]]+bundle' \
       "$WS" --include='*.sh' --include='*.yml' --include='*.yaml' --include='Makefile' --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=versions --exclude='*.test.sh' --exclude='check-*.sh' 2>/dev/null | grep -vE '#.*(check-deploy-git: ok|build-teste)' | grep -q .; then
    bad 13 "scp/rsync remoto/tar|ssh/docker save|load/git bundle em scripts de deploy/CI/ops (piso 23: deploy só do git)"
  else ok 13 "sem scp/rsync/tar|ssh nos scripts (grep local; use a engineering p/ o gate completo)"; fi
fi

# 14 / piso 24 — ops é o gate da IA
if [ -z "$OPS" ]; then bad 14 "sem <projeto>_ops — o ops é o gate da IA na plataforma (piso 24)"
else
  if grep -rqiE 'allow-?list|operacoes? tipadas?|operações? tipadas?' "$OPS" --exclude-dir=.git 2>/dev/null; then ok 14 "ops traz allowlist de operações tipadas"; else bad 14 "ops sem allowlist de operações nomeadas/tipadas (a IA nunca escreve SQL/comando próprio)"; fi
  if grep -rqiE 'audit|auditoria' "$OPS" --exclude-dir=.git 2>/dev/null; then ok 14 "ops traz log de auditoria"; else bad 14 "ops sem log de auditoria append-only"; fi
fi

# 15 / pisos 25-26 — ritmo, relatórios, custos
if [ -z "$ARCH" ]; then bad 15 "sem <projeto>_archive"
else
  ls "$ARCH"/relatorios/*.md >/dev/null 2>&1 && ok 15 "relatorios/ com relatório" || bad 15 "archive sem relatorios/*.md (relatório a cada 30 min, piso 26)"
  [ -d "$ARCH/custos" ] && ok 15 "custos/ existe" || bad 15 "archive sem custos/ (custos.{json,md} do app: schematize cost sync|report)"
  R="$ARCH/.ritmo.json"
  if [ ! -f "$R" ]; then bad 15 "archive sem .ritmo.json ({ultimo_relatorio, ultimo_handoff})"
  else
    iso='"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}'
    tr -d '\n' < "$R" | grep -qE "\"ultimo_relatorio\"[[:space:]]*:[[:space:]]*$iso" && tr -d '\n' < "$R" | grep -qE "\"ultimo_handoff\"[[:space:]]*:[[:space:]]*$iso" \
      && ok 15 ".ritmo.json com os dois carimbos ISO-8601" || bad 15 ".ritmo.json sem ultimo_relatorio/ultimo_handoff em ISO-8601"
    if [ "$ATIVO" -eq 1 ]; then
      if [ -n "$ENG" ] && [ -f "$ENG/check-ritmo.sh" ]; then bash "$ENG/check-ritmo.sh" "$ARCH" >/dev/null 2>&1 && ok 15 "ritmo em dia (30 min/6 h)" || bad 15 "ritmo vencido: gere relatório/handoff ANTES da próxima ação"
      else bad 15 "--ativo pede o check-ritmo.sh da engineering (use --eng DIR)"; fi
    fi
  fi
fi

# 16 / piso 27 — gatilhos de CI
NWF=0
for r in "${REPOS[@]}"; do
  case "$r" in *_archive) continue ;; esac
  n="$(basename "$(cd "$r" && pwd)")"; shopt -s nullglob; wfs=("$r"/.github/workflows/*.yml "$r"/.github/workflows/*.yaml); shopt -u nullglob
  if [ "${#wfs[@]}" -eq 0 ]; then bad 16 "$n: sem .github/workflows/ci.yml (copie assets/templates/ci.yml.tpl)"; continue; fi
  for w in "${wfs[@]}"; do
    NWF=$((NWF+1)); wn="$n/${w##*/}"
    if [ -f "$r/ci-triggers-allow.txt" ] && grep -qxF "${w##*/}" "$r/ci-triggers-allow.txt"; then ok 16 "$wn: isento (ci-triggers-allow.txt)"; continue; fi
    pre="$(grep -vE '^[[:space:]]*#' "$w")"
    if printf '%s\n' "$pre" | grep -qE '^[[:space:]]*(pull_request|pull_request_target|workflow_run|merge_group|schedule)[[:space:]]*:' \
       || printf '%s\n' "$pre" | grep -qE '^on:[[:space:]]*(\[.*(pull_request|push|schedule|workflow_run|merge_group)|(pull_request|push|schedule))' \
       || printf '%s\n' "$pre" | grep -qE '^[[:space:]]+(branches|branches-ignore|tags-ignore):'; then
      bad 16 "$wn: gatilho vetado (pull_request/push em branch/workflow_run/merge_group/schedule) — use workflow_dispatch + push tags [hml-*, v*]"; continue; fi
    printf '%s\n' "$pre" | grep -qE '^[[:space:]]*workflow_dispatch[[:space:]]*:' || { bad 16 "$wn: sem workflow_dispatch"; continue; }
    printf '%s\n' "$pre" | grep -qE 'cancel-in-progress:[[:space:]]*true' || { bad 16 "$wn: sem concurrency cancel-in-progress: true"; continue; }
    ok 16 "$wn: dispatch + tags, concurrency ok"
  done
done

# 17 / piso 28 — microserviço autônomo
for r in "${REPOS[@]}"; do
  n="$(basename "$(cd "$r" && pwd)")"
  case "$n" in *_archive|*_ops|*_front|*_authfront) continue ;; esac
  [[ "$n" =~ _(go|rs|ex|cs|zig|rb)$ ]] || continue
  if [ ! -f "$r/resilience.yml" ]; then bad 17 "$n: sem resilience.yml (service + dependencies) — piso 28"; continue; fi
  if [ -n "$ENG" ] && [ -f "$ENG/check-resilience.sh" ]; then
    bash "$ENG/check-resilience.sh" "$r" >/dev/null 2>&1 && ok 17 "$n: 7 testes de resiliência (M == N)" || bad 17 "$n: faltam testes de resiliência (rode check-resilience.sh)"
  else ok 17 "$n: resilience.yml presente (sem gate da engineering à mão para provar os 7 testes)"; fi
done

# 18 / piso 29 — máquina de build dev/hml
MQ=""; for c in "$OPS/maquinas.yml" "$ARCH/maquinas.yml" "$WS/maquinas.yml"; do [ -f "$c" ] && { MQ="$c"; break; }; done
if [ -z "$MQ" ]; then ok 18 "sem maquinas.yml: build local (piso 29a)"
else
  if grep -qE '^[[:space:]-]*env:[[:space:]]*"?(prd|prod|production|staging|stg)"?[[:space:]]*(#.*)?$' "$MQ"; then bad 18 "maquinas.yml com env prd/staging — só dev|hml (piso 29)"
  elif ! grep -qE '^[[:space:]-]*env:[[:space:]]*"?(dev|hml)"?' "$MQ"; then bad 18 "maquinas.yml sem env: dev|hml"
  elif ! grep -qE 'papel:[[:space:]]*"?build-teste' "$MQ"; then bad 18 "maquinas.yml sem papel: build-teste"
  else ok 18 "maquinas.yml: env dev|hml, papel build-teste"; fi
fi

[ "$FAIL" -eq 0 ] && { echo "check-piso22-29: ok"; exit 0; }
echo "check-piso22-29: REPROVADO"; exit 1
