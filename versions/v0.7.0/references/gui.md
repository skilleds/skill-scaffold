# Integração com a GUI — botões da sua skill (`gui.json`)

Uma skill instalada pode **aparecer como botões** na GUI do schematize (aba do projeto) sem nenhum
hardcode no app. Basta declarar as ações num arquivo **`gui.json`** na RAIZ da skill (ao lado do
`SKILL.md`/`skill.toml`). Quando a skill está instalada, a GUI lê esse arquivo e desenha um botão por
ação; clicar dispara o `command` no `claude` de um terminal externo, no projeto selecionado.

É assim que **Q.A.** (`schematize-engineering`) e **Pentest** (`schematize-pentest`) aparecem — cada
uma traz seu `gui.json`. Skills novas plugam do mesmo jeito.

## Formato

```json
{
  "actions": [
    { "label": "Q.A.", "command": "/qa-plan", "needs_project": true, "context": "project", "order": 10 }
  ]
}
```

Campos de cada ação:

| campo          | tipo   | default     | o que faz                                                                 |
|----------------|--------|-------------|---------------------------------------------------------------------------|
| `label`        | string | (obrigat.)  | rótulo do botão (curto: "Q.A.", "Pentest").                               |
| `command`      | string | (obrigat.)  | o que é enviado ao `claude` ao clicar — um slash-command (`/qa-plan`) ou um prompt. O comando tem de EXISTIR em `assets/commands/` de alguma skill: botão apontando para comando removido é botão morto, e o lint do catálogo (`ref-comando`) reprova. |
| `needs_project`| bool   | `false`     | só habilita o botão com um projeto selecionado.                          |
| `context`      | string | `"project"` | onde aparece: `"project"` (aba do projeto) ou `"global"` (sempre).       |
| `order`        | int    | `0`         | ordenação entre as ações (menor primeiro).                               |

## Regras

- O `command` é um **slash-command da própria skill** (um `.md` em `assets/commands/`),
  então o botão só faz sentido quando a skill instala esse comando. Prefira comandos **plan-first**
  (que confirmam antes de executar) pra ações sensíveis — ex.: `/pentest-plan`, não um ataque direto.
- O `gui.json` tem que ir **dentro do release** (o `.zip` publicado), senão `schematize skills update`
  não o traz. Inclua-o no empacotamento como qualquer outro arquivo da skill.
- Sem `gui.json`, a skill simplesmente não declara botões — é opcional e retrocompatível.
- A GUI resolve tudo **offline**, varrendo `~/.claude/skills/<skill>/gui.json` — não depende de rede.

## Como testar

1. Ponha o `gui.json` na raiz da skill e instale-a (`schematize skills install <slug>`), ou copie o
   arquivo direto pra `~/.claude/skills/schematize-<slug>/gui.json`.
2. Abra a GUI, selecione um projeto: o botão aparece na seção **"Ações de skills"** da aba Overdev.
3. Clique — o `claude` abre num terminal externo já rodando o `command`.
