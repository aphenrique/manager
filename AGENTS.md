# Manager — Orquestrador de Contexto

## Context Engineering

O agente principal é um **orquestrador**, não um executor.

- **Papel do agente principal:** coordenar arquivos, delegar para sub-agents, processar sumários, comunicar com o usuário
- **Agente principal NUNCA:** explora o codebase extensamente, implementa código, roda builds/testes diretamente — tudo isso é delegado a sub-agents

### Protocolo de Sub-agents

- Cada prompt de sub-agent termina com: "Retorne um sumário estruturado: [campos exatos]"
- Nunca peça a um sub-agent para "retornar tudo"
- Alvo: 10–20 linhas de informação acionável por resultado
- Encadeie sub-agents passando apenas os campos relevantes

## Model Assignment

| Tarefa | Modelo |
|--------|--------|
| Varredura de arquivos, descoberta, análise de deps | haiku |
| Fixes simples (lint, format, typos, CSS) | haiku |
| Atualizações de documentação | haiku |
| Implementação padrão | sonnet |
| Investigação de bugs e análise de causa raiz | sonnet |
| Escrita de testes | sonnet |
| Refatoração complexa multi-arquivo | opus |
| Decisões arquiteturais | opus |

## Regras do Projeto

- Usar `mix precommit` (ou `scripts/precommit-check.sh`) ao finalizar mudanças
- HTTP requests: usar `:req` (Req) — **nunca** `:httpoison`, `:tesla`, `:httpc`

## Índice de Documentação (lazy-load — leia apenas o necessário)

| Tópico | Localização |
|--------|-------------|
| Plano de arquitetura | `docs/PLANO.md` |
| Phoenix v1.8, layouts, componentes | `.claude/skills/elixir-dev/references/phoenix-v18.md` |
| JS & CSS (Tailwind v4) | `.claude/skills/elixir-dev/references/js-css.md` |
| Autenticação (phx.gen.auth) | `.claude/skills/elixir-dev/references/auth.md` |
| Elixir — linguagem, Mix, testes | `.claude/skills/elixir-dev/references/elixir-lang.md` |
| Ecto, changesets, migrações | `.claude/skills/elixir-dev/references/ecto.md` |
| LiveView (core, streams, JS hooks) | `.claude/skills/elixir-dev/references/liveview-core.md` |
| LiveView — formulários | `.claude/skills/elixir-dev/references/liveview-forms.md` |
| LiveView — testes, HEEx syntax | `.claude/skills/elixir-dev/references/liveview-tests.md` |

## Skills Disponíveis

- `/elixir-dev` — carrega guidelines completos de Elixir/Phoenix antes de codar
- `/qa` — executa sessão de QA contra o servidor Phoenix local
