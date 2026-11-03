#!/usr/bin/env bash
# check-day0-auth.sh — gate determinístico de DUAS peças do piso do dia 0:
#   (A) matriz de acesso por rota (piso 20 da schematize-engineering): existe teste de matriz de acesso
#       (anônimo / não privilegiado / privilegiado / burlas) e o gate de inventário (M == N) está no CI;
#   (B) passkey/WebAuthn na FASE 0 (piso 21): existe evidência de teste de passkey cobrindo challenge
#       reutilizado, origin/rpId errado e credencial revogada.
# Detalhe do teste de matriz: `schematize-qa` (scripts/check-route-authz.sh); IAM: `schematize-iam`.
#
# Uso:  bash scripts/check-day0-auth.sh [dir]     (default: .)
# Sai 1 se faltar qualquer das evidências. O que NÃO faz: julgar a qualidade do teste (isso é revisão
# e o vermelho visto da QA); aqui é a presença que grep prova sozinho.

# EXCEÇÃO DECLARADA de strict mode (`schematize-shell` -> `references/piso.md` secao 1):
# COLETOR — soma os achados em vez de abortar no primeiro; por isso `set -uo pipefail` sem `-e`.
set -uo pipefail
DIR="${1:-.}"
FAIL=0
RED=$'\033[0;31m'; GRN=$'\033[0;32m'; RST=$'\033[0m'
block() { echo "${RED}✗ BLOQUEIA${RST} $1"; FAIL=1; }
ok()    { echo "${GRN}✔${RST} $1"; }
EXCL=(-not -path '*/.git/*' -not -path '*/node_modules/*' -not -path '*/target/*' -not -path '*/vendor/*' -not -path '*/dist/*' -not -path '*/.next/*')

echo "== check-day0-auth (dir: $DIR) =="

# Só conta DECLARAÇÃO de teste (fn/func/def/it/test/describe/[Fact]/@Test/#[test]) fora de comentário e
# fora de .md: palavra em README, comentário ou string solta NÃO prova nada (achado G8 P1: falso verde).
DECL='^[[:space:]]*(#\[test\]|\[Fact\]|@Test|(async[[:space:]]+)?(fn|func|def|function|it|test|describe|void|Task)[[:space:](])'
decls() { grep -E "$DECL" "$1" 2>/dev/null | grep -vE '^[[:space:]]*(//|#[^[]|--)'; }
mapfile -t TESTES < <(find "$DIR" -type f \( -path '*test*' -o -path '*spec*' -o -name '*_test.*' -o -name '*.test.*' -o -name '*.spec.*' \) "${EXCL[@]}" -not -name '*.md' -not -name '*.txt' -not -name '*.yml' -not -name '*.yaml' 2>/dev/null)

# (A) teste de matriz de acesso: declaração de teste que cita a matriz (nome do arquivo OU da função).
A_TESTE=0
for f in "${TESTES[@]}"; do
  if decls "$f" | grep -qiE 'access[ _-]?matrix|matriz[ _-]?(de[ _-])?acesso|route[ _-]?authz|authz[ _-]?matrix' \
     || { [[ "$f" =~ (access[-_]?matrix|matriz[-_]?(de[-_])?acesso|route[-_]?authz|authz[-_]?matrix) ]] && decls "$f" | grep -q .; }; then A_TESTE=1; break; fi
done
if [ "$A_TESTE" -eq 1 ]; then ok "teste de matriz de acesso por rota existe"; else block "nenhum teste de matriz de acesso por rota (4 personas, status e corpo) — rota nasce com teste (piso 20)"; fi

# (A) gate M == N no CI: check-route-authz.sh chamado de verdade (linha não comentada) em pipeline/Makefile/ops.
if grep -rhsE 'check-route-authz' "$DIR" --include='*.yml' --include='*.yaml' --include='Makefile' --include='*.mk' --include='*.sh' --include='*.toml' --exclude-dir=.git --exclude-dir=node_modules --exclude=check-day0-auth*.sh 2>/dev/null | grep -vE '^[[:space:]]*(#|//)' | grep -q .; then
  ok "gate check-route-authz.sh (M == N) plugado no CI"
else
  block "gate check-route-authz.sh não está plugado no CI (linha executável, não comentário) — rota nova sem linha na matriz precisa quebrar o build (M == N)"
fi

# (B) passkey: declarações de teste que cobrem os 3 negativos obrigatórios da fase 0 (challenge, origin/rpId, revogada).
B_OK=0
for f in "${TESTES[@]}"; do
  D="$(decls "$f")"
  if grep -qiE 'passkey|webauthn' "$f" 2>/dev/null \
     && grep -qiE 'challenge' <<<"$D" && grep -qiE 'rp_?id|origin' <<<"$D" && grep -qiE 'revoked|revogad|revoke' <<<"$D"; then B_OK=1; break; fi
done
if [ "$B_OK" -eq 1 ]; then ok "teste de passkey cobre challenge reutilizado, origin/rpId errado e credencial revogada"; else block "sem evidência de teste de passkey na fase 0 (declaração de teste p/ registro, login, challenge reutilizado, origin/rpId errado, credencial revogada) — piso 21"; fi

if [ "$FAIL" -ne 0 ]; then echo "check-day0-auth: REPROVADO"; exit 1; fi
echo "check-day0-auth: ok"
