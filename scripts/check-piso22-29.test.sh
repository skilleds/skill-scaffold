#!/usr/bin/env bash
# check-piso22-29.test.sh — o VERMELHO VISTO do gate das peças 12-18 (pisos 22-29).
# Planta um workspace limpo (exit 0) e cada furo (exit 1). Saída: exit 0 todos passam, exit 1 algum falhou.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# harness de teste sem `-e` de propósito — reporta TODOS os casos, não só o primeiro vermelho.
set -uo pipefail
G="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/check-piso22-29.sh"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
rc=0
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
esperar() { # exit-esperado nome dir
  OUT=$(bash "$G" "$3" 2>&1); z=$?
  if [ "$z" -eq "$1" ]; then echo "  ok $2 (exit $z)"; else echo "  FALHOU $2: exit $z, esperado $1: $OUT"; rc=1; fi
}
# repo <ws> <nome>: cria repo com commit empurrado para um bare local (remote + upstream)
repo() {
  mkdir -p "$1/$2"; git -C "$1/$2" init -q -b main; git init -q --bare "$1/.remotes/$2.git"
  git -C "$1/$2" remote add origin "$1/.remotes/$2.git"
  printf 'x\n' > "$1/$2/README.md"
}
publicar() { git -C "$1/$2" add -A && git -C "$1/$2" commit -qm i && git -C "$1/$2" push -q -u origin main; }
mk_ok() {
  local w="$1" p=demo
  mkdir -p "$w"
  for n in ${p}_core_go ${p}_ops ${p}_archive; do repo "$w" $n; done
  mkdir -p "$w/${p}_core_go/.github/workflows"
  cat > "$w/${p}_core_go/.github/workflows/ci.yml" <<'Y'
name: ci
on:
  workflow_dispatch:
  push:
    tags: ["hml-*", "v*"]
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs: {}
Y
  printf 'service: core\ndependencies: []\n' > "$w/${p}_core_go/resilience.yml"
  printf 'func TestBootSemDependencias(t *testing.T) {}\nfunc TestShutdownGracioso(t *testing.T) {}\nfunc TestCrashEntrePersistirEConfirmar(t *testing.T) {}\n' > "$w/${p}_core_go/resilience_test.go"
  mkdir -p "$w/${p}_ops/.github/workflows"; cp "$w/${p}_core_go/.github/workflows/ci.yml" "$w/${p}_ops/.github/workflows/ci.yml"
  printf '# allowlist de operacoes tipadas\n# log de auditoria append-only (audit)\n' > "$w/${p}_ops/OPS.md"
  mkdir -p "$w/${p}_archive/relatorios" "$w/${p}_archive/custos"
  printf '# r\n' > "$w/${p}_archive/relatorios/2026-11-01_1000.md"; : > "$w/${p}_archive/custos/.keep"
  printf '{"ultimo_relatorio":"2026-11-01T10:00:00Z","ultimo_handoff":"2026-11-01T10:00:00Z"}\n' > "$w/${p}_archive/.ritmo.json"
  for n in ${p}_core_go ${p}_ops ${p}_archive; do publicar "$w" $n; done
}

echo "-- workspace completo passa"; mk_ok "$W/ok"; esperar 0 "completo" "$W/ok"
echo "-- sem remote BLOQUEIA (22)"; mk_ok "$W/a"; git -C "$W/a/demo_core_go" remote remove origin; esperar 1 "sem remote" "$W/a"
echo "-- arvore suja BLOQUEIA (22)"; mk_ok "$W/b"; echo y >> "$W/b/demo_core_go/README.md"; esperar 1 "suja" "$W/b"
echo "-- commit sem push BLOQUEIA (22)"; mk_ok "$W/c"; echo y >> "$W/c/demo_core_go/README.md"; git -C "$W/c/demo_core_go" commit -qam z; esperar 1 "HEAD!=origin" "$W/c"
echo "-- scp no deploy BLOQUEIA (23)"; mk_ok "$W/d"; printf 'scp -r build host:/srv/app\n' > "$W/d/demo_ops/deploy.sh"; publicar "$W/d" demo_ops; esperar 1 "scp" "$W/d"
echo "-- ops sem allowlist/audit BLOQUEIA (24)"; mk_ok "$W/e"; : > "$W/e/demo_ops/OPS.md"; publicar "$W/e" demo_ops; esperar 1 "ops cru" "$W/e"
echo "-- sem .ritmo.json BLOQUEIA (26)"; mk_ok "$W/f"; rm "$W/f/demo_archive/.ritmo.json"; publicar "$W/f" demo_archive; esperar 1 "sem ritmo" "$W/f"
echo "-- sem custos/ BLOQUEIA (26)"; mk_ok "$W/g"; rm -r "$W/g/demo_archive/custos"; esperar 1 "sem custos" "$W/g"
echo "-- CI com pull_request BLOQUEIA (27)"; mk_ok "$W/h"
printf 'name: ci\non:\n  pull_request:\n  workflow_dispatch:\nconcurrency:\n  cancel-in-progress: true\njobs: {}\n' > "$W/h/demo_core_go/.github/workflows/ci.yml"; publicar "$W/h" demo_core_go; esperar 1 "pull_request" "$W/h"
echo "-- CI com push em branch BLOQUEIA (27)"; mk_ok "$W/i"
printf 'name: ci\non:\n  workflow_dispatch:\n  push:\n    branches: [main]\nconcurrency:\n  cancel-in-progress: true\njobs: {}\n' > "$W/i/demo_core_go/.github/workflows/ci.yml"; publicar "$W/i" demo_core_go; esperar 1 "push branches" "$W/i"
echo "-- CI sem concurrency BLOQUEIA (27)"; mk_ok "$W/j"
printf 'name: ci\non:\n  workflow_dispatch:\njobs: {}\n' > "$W/j/demo_core_go/.github/workflows/ci.yml"; publicar "$W/j" demo_core_go; esperar 1 "sem concurrency" "$W/j"
echo "-- servico sem resilience.yml BLOQUEIA (28)"; mk_ok "$W/k"; rm "$W/k/demo_core_go/resilience.yml"; publicar "$W/k" demo_core_go; esperar 1 "sem resilience" "$W/k"
echo "-- maquinas.yml com prd BLOQUEIA (29)"; mk_ok "$W/l"; printf -- '- nome: b\n  env: prd\n  papel: build-teste\n' > "$W/l/demo_ops/maquinas.yml"; publicar "$W/l" demo_ops; esperar 1 "env prd" "$W/l"
echo "-- maquinas.yml hml/build-teste passa (29)"; mk_ok "$W/m"; printf -- '- nome: b\n  env: hml\n  papel: build-teste\n' > "$W/m/demo_ops/maquinas.yml"; publicar "$W/m" demo_ops; esperar 0 "maquinas ok" "$W/m"
exit "$rc"
