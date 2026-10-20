# .env.example — o CONTRATO de configuracao do projeto. Entra no repo; o `.env` real NUNCA entra.
#
# Regra: toda variavel que a app le tem de estar AQUI, com um valor de exemplo seguro e um
# comentario dizendo o que e. Variavel que so existe no `.env` de alguem e config invisivel — o
# proximo dev descobre no crash.
#
# Piso fail-closed: config AUSENTE assume o modo SEGURO (nao-producao, sink, deny). Nunca o
# contrario.

# --- Ambiente -----------------------------------------------------------------
# prd | prod | production ligam o modo real. Ausente/desconhecido => NAO-producao.
APP_ENV=dev

# --- Banco --------------------------------------------------------------------
DATABASE_URL=postgres://app:app@localhost:5432/app_dev

# --- IAM / auth (app SEPARADA, em auth.<domain>) ------------------------------
AUTH_ISSUER_URL=http://localhost:8787
AUTH_CLIENT_ID=app-local
# AUTH_CLIENT_SECRET fica no cofre, nunca aqui e nunca no cliente.

# --- EFEITO EXTERNO: as 4 camadas do piso (ADR-0004) --------------------------
# 1) provider default = SINK fora de prd. `smtp`/real so em producao.
MAIL_PROVIDER=sink
# 2) o sink local (Mailpit) — e dele que o TESTE le a caixa, nunca de caixa real.
MAIL_SINK_API=http://localhost:8025
# 3) dominio de teste em ROTA NULA (null MX + SPF -all + DMARC p=reject).
#    Todo endereco sintetico de fixture/seed/persona vive aqui.
TEST_MAIL_DOMAIN=test.example.test
# 4) cap por execucao — vale em TODOS os ambientes; e freio, nao camada de sandbox.
MAIL_MAX_PER_RUN=50

# --- Observabilidade -----------------------------------------------------------
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
OTEL_SERVICE_NAME=app
LOG_LEVEL=info
