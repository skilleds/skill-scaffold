# ci.yml.tpl -> copie para .github/workflows/ci.yml de CADA repo de código (piso 27 da schematize-engineering).
# CI remoto NÃO roda por commit nem por PR. O gate por commit é LOCAL (tools/ci.sh / pre-commit / pre-push).
# Roda só: (a) UMA vez antes de promover a hml (tag hml-*), (b) em release (tag v*), (c) sob pedido (workflow_dispatch).
# VETADO: pull_request, pull_request_target, push em branch, workflow_run, merge_group, schedule (sem ADR).
# Gate: scripts/check-piso22-29.sh (peça 16) e check-ci-triggers.sh da engineering reprovam o que fugir disso.
name: ci
on:
  workflow_dispatch:
  push:
    tags: ["hml-*", "v*"]
    paths-ignore: ["**.md", "docs/**", "*_archive/**"]

concurrency:
  group: ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read

jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      # Fixe por SHA (comente a versão). <SHA> = commit da release oficial da action.
      - uses: actions/checkout@<SHA> # vX.Y.Z
        with: { fetch-depth: 0 }
      - name: Gate local da casa (mesmo script do pre-push)
        run: bash tools/ci.sh
      # Test kit + piso: troque pelo comando REAL do projeto. Placeholder reprova de propósito (verde de mentira é vetado).
      - name: Test kit (smoke + security + authz + resiliência)
        run: |
          echo "ERRO: ligue o test kit do <projeto>_ops antes de usar este template" >&2
          exit 1
      - name: Matriz de acesso por rota (piso 20, M == N)
        run: bash .claude/skills/schematize-qa/scripts/check-route-authz.sh
      - name: Piso 22-29 (git, deploy, ritmo, CI, resiliência, build host)
        run: bash .claude/skills/schematize-scaffold/scripts/check-piso22-29.sh .
