# .gitignore — piso do dia 0 da casa. Copie para a raiz de CADA repo do projeto.
#
# Regra por tras da lista: o repo guarda FONTE e CONTRATO. Tudo que e derivado (build, cache),
# efemero (log, tmp) ou SECRETO (env real, chave) fica fora — e o que e secreto tem de estar aqui
# ANTES do primeiro commit, porque segredo commitado uma vez esta vazado para sempre (rotacione,
# nao "remova o commit").

# --- SEGREDO: o mais importante da lista -------------------------------------
.env
.env.*
!.env.example          # o EXEMPLO entra no repo — e nunca tem valor real dentro
*.pem
*.key
*.p12
*.pfx
*.jks
*.keystore
id_rsa*
credentials.json
service-account*.json
secrets.*.yaml

# --- Control-plane operacional (nao e fonte, nao e artefato) -----------------
.schematize/           # overdev + grafos: estado vivo da maquina, nao do repo
                       # (o <projeto>_archive/ NAO entra aqui: ele e repo git proprio)

# --- Build e cache derivados --------------------------------------------------
node_modules/
dist/
build/
out/
.next/
.astro/
.turbo/
.cache/
coverage/
target/                # Rust
bin/  obj/             # .NET
_build/  deps/         # Elixir
zig-out/  .zig-cache/  # Zig
vendor/bundle/         # Ruby
__pycache__/
*.pyc

# --- Sistema operacional e editor --------------------------------------------
.DS_Store
Thumbs.db
*.swp
.idea/
.vscode/*
!.vscode/extensions.json   # recomendacao de extensao e util para o time

# --- Efemeros ------------------------------------------------------------------
*.log
logs/
tmp/
.tmp/
*.pid

# --- Artefato de release ------------------------------------------------------
*.zip
*.tar.gz
