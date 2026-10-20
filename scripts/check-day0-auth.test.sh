#!/usr/bin/env bash
# check-day0-auth.test.sh — o VERMELHO VISTO do gate de matriz de acesso + passkey do dia 0.
# Planta o caso limpo (exit 0) e cada omissão (exit 1). Saída: exit 0 todos passam, exit 1 algum falhou.
# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# harness de teste sem `-e` de propósito — reporta TODOS os casos, não só o primeiro vermelho.
set -uo pipefail
G="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/check-day0-auth.sh"
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
rc=0
esperar() { # exit-esperado nome dir
  OUT=$(bash "$G" "$3" 2>&1); z=$?
  if [ "$z" -eq "$1" ]; then echo "  ✔ $2 (exit $z)"; else echo "  ✖ $2: exit $z, esperado $1: $OUT"; rc=1; fi
}
mk_completo() {
  mkdir -p "$1/tests" "$1/.github/workflows"
  printf 'def test_access_matrix_anonimo_401(): pass\n' > "$1/tests/test_access_matrix.py"
  printf 'def test_passkey(): challenge reutilizado; origin e rpId errado; credencial revogada\n' > "$1/tests/test_passkey.py"
  printf 'steps:\n  - run: bash scripts/check-route-authz.sh\n' > "$1/.github/workflows/ci.yml"
}

echo "── projeto completo passa"; mk_completo "$W/ok"; esperar 0 "completo" "$W/ok"
echo "── sem teste de matriz BLOQUEIA"; mk_completo "$W/a"; rm "$W/a/tests/test_access_matrix.py"; esperar 1 "sem matriz" "$W/a"
echo "── sem gate M == N no CI BLOQUEIA"; mk_completo "$W/b"; printf 'steps: []\n' > "$W/b/.github/workflows/ci.yml"; esperar 1 "sem gate CI" "$W/b"
echo "── sem teste de passkey BLOQUEIA"; mk_completo "$W/c"; rm "$W/c/tests/test_passkey.py"; esperar 1 "sem passkey" "$W/c"
echo "── passkey sem os negativos (só registro) BLOQUEIA"; mk_completo "$W/d"; printf 'def test_passkey_registro(): pass\n' > "$W/d/tests/test_passkey.py"; esperar 1 "passkey parcial" "$W/d"
exit "$rc"
