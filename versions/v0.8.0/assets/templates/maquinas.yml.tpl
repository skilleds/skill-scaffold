# maquinas.yml.tpl -> <projeto>_ops/maquinas.yml (piso 29). OPCIONAL: sem máquina dev/hml, o build é local.
# env ∈ {dev, hml} (hml, nunca staging; NUNCA prd). A ponte direta (rsync/ssh) vale SÓ p/ build/teste,
# dentro do workspace remoto; o que ela produz NUNCA é promovível (promover = commit+push + build limpo do git).
- nome: build-hml-1
  host: build.hml.<domain>
  env: hml
  papel: build-teste
  ponte_direta: true
  workspace: /var/tmp/schematize-build/<projeto>/
  limites: { disco_pct: 80, cpu: 4 }
