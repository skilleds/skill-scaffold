# resilience.yml.tpl -> raiz de CADA serviço (piso 28). Matriz M == N: uma dependência declarada = um teste
# de indisponibilidade nomeado. Gate: schematize-engineering/scripts/check-resilience.sh <dir-do-servico>.
service: <ctx>
# consumes_queue: true     # descomente se consome fila externa (mantém testes 3, 4 e 5)
dependencies:
  - auth        # remova/adicione os vizinhos de que o serviço depende; `dependencies: []` se for folha
# Os 7 testes obrigatórios nascem VERMELHOS (esqueleto) com estes nomes:
#   boot_sem_dependencias · dependencia_indisponivel (um por dep, com o nome dela na linha)
#   restart_fila_cheia · reentrega_idempotente · dlq_envenenada · shutdown_gracioso
#   crash_entre_persistir_e_confirmar
