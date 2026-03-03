# Plano: App de Gestão Financeira (Phoenix + Telegram)

## Contexto
Construir um app de gestão financeira pessoal do zero. Controle total de gastos e receitas por conta/cartão de crédito, com lançamento via bot do Telegram (canal de entrada stateless) e relatórios detalhados. Interface web exclusivamente em dark theme com Phoenix LiveView e DaisyUI.

---

## Stack e Versões

- **Elixir** 1.19.4 / OTP 28
- **Phoenix** ~1.8 + **LiveView** ~1.1 + **DaisyUI** (já incluso no Phoenix)
- **Banco**: SQLite via `ecto_sqlite3`
- **Telegram**: `ex_gram ~> 0.58` (webhook mode, stateless)
- **Datas**: stdlib Elixir (`Date`, `DateTime`, `Calendar`) — sem Timex

---

## 1. Setup do Projeto

```bash
mix archive.install hex phx_new
mix phx.new manager \
  --database sqlite3 \
  --live \
  --no-mailer \
  --module Manager \
  --app manager
cd manager
```

### Dependências adicionais em `mix.exs`

```elixir
{:decimal, "~> 2.3"},    # aritmética monetária segura
{:ex_gram, "~> 0.58"},   # Telegram bot
{:tesla, "~> 1.11"},     # adapter HTTP do ex_gram
{:hackney, "~> 1.23"},   # adapter Tesla
```

---

## 2. Dark Theme com DaisyUI

Phoenix 1.8 já inclui DaisyUI. Forçar dark theme permanentemente:

**`tailwind.config.js`**
```js
module.exports = {
  daisyui: { themes: ["dark"] },
  plugins: [require("daisyui")],
}
```

**`root.html.heex`**
```html
<html lang="pt-BR" data-theme="dark">
```

### Tokens DaisyUI usados no projeto

| Contexto | Token |
|----------|-------|
| Background base | `bg-base-100` |
| Cards/surfaces | `bg-base-200` |
| Texto | `text-base-content` |
| Receitas | `text-success` |
| Despesas | `text-error` |
| Accent/ações | `text-primary` |

---

## 3. Schema do Banco de Dados

> Nenhuma referência ao Telegram no banco. O bot é canal de entrada stateless.

### Ordem de migrations

```
1. categories
2. accounts
3. credit_cards
4. credit_card_bills
5. transactions
```

### Tabelas

**categories**
```
id, name:string, color:string, icon:string,
type:string (income|expense|both), inserted_at, updated_at
```

**accounts**
```
id, name:string, type:string (checking|savings|investment|wallet),
initial_balance:decimal, currency:string (default "BRL"),
color:string, icon:string, active:boolean, inserted_at, updated_at
```
> `initial_balance` = saldo inicial. Saldo atual calculado via transações.

**credit_cards**
```
id, name:string, limit:decimal, closing_day:integer, due_day:integer,
color:string, active:boolean,
account_id:references(accounts) nullable,  -- conta usada para pagar fatura
inserted_at, updated_at
```

**credit_card_bills** — faturas mensais
```
id, credit_card_id:references(credit_cards),
reference_month:date (primeiro dia do mês),
closing_date:date, due_date:date,
total_amount:decimal,
status:string (open|closed|paid),
paid_at:date nullable,
inserted_at, updated_at
```

**transactions**
```
id, description:string, amount:decimal,
type:string (income|expense|transfer),
date:date, notes:text,
account_id:references(accounts) nullable,
credit_card_id:references(credit_cards) nullable,
credit_card_bill_id:references(credit_card_bills) nullable,
category_id:references(categories) nullable,
inserted_at, updated_at
```

---

## 4. Modelo de Cartão de Crédito

O cartão **não é uma conta com saldo negativo**. Usa ciclo de faturas:

```
[após fechamento] → compras → fatura OPEN
       ↓
[closing_day] → fatura fecha → status CLOSED, total_amount calculado
       ↓
[due_day] → vencimento
       ↓
[pagamento] → transação expense na conta bancária → fatura PAID
```

- Gasto no cartão → sistema encontra (ou cria) a fatura OPEN atual
- **Saldo atual do cartão** = `SUM(transactions WHERE bill.status = 'open')`
- **Limite disponível** = `limit - saldo_atual`
- **Pagar fatura** = criar `expense` na conta bancária + marcar bill como PAID

---

## 5. Contexts Phoenix

### `Manager.Finance.Accounts`
- `list_accounts/0`, `get_account!/1`
- `create_account/1`, `update_account/2`, `delete_account/1`
- `current_balance/1` — initial_balance + soma das transações

### `Manager.Finance.CreditCards`
- `list_credit_cards/0`, `get_credit_card!/1`
- `create_credit_card/1`, `update_credit_card/2`
- `get_or_create_open_bill/1` — fatura OPEN atual (cria se não existir)
- `close_bill/1` — fecha fatura, calcula total_amount
- `pay_bill/2` — marca PAID + cria transação expense na conta

### `Manager.Finance.Transactions`
- `list_transactions/1` — filtros: conta, período, categoria, tipo
- `create_transaction/1`, `update_transaction/2`, `delete_transaction/1`
- `monthly_summary/2` — total income/expense por mês
- `category_breakdown/2` — gastos por categoria
- `spending_trend/1` — últimos N meses

### `Manager.Finance.Categories`
- `list_categories/0`, `list_categories_by_type/1`
- `create_category/1`, `update_category/2`

---

## 6. LiveView Pages

| Rota | Módulo | Descrição |
|------|--------|-----------|
| `/` | `DashboardLive` | Saldos, últimas transações, gráfico mensal |
| `/accounts` | `AccountsLive.Index` | Lista e CRUD de contas |
| `/accounts/:id` | `AccountsLive.Show` | Extrato da conta |
| `/credit-cards` | `CreditCardsLive.Index` | Lista e CRUD de cartões |
| `/credit-cards/:id` | `CreditCardsLive.Show` | Fatura atual + histórico |
| `/transactions` | `TransactionsLive.Index` | Todas transações + filtros |
| `/transactions/new` | `TransactionsLive.New` | Formulário de lançamento |
| `/categories` | `CategoriesLive.Index` | CRUD de categorias |
| `/reports` | `ReportsLive` | Relatórios e gráficos |

---

## 7. Autenticação

```bash
mix phx.gen.auth Accounts User users
```

Todas as rotas dentro do scope autenticado:
```elixir
scope "/", ManagerWeb do
  pipe_through [:browser, :require_authenticated_user]
  live "/", DashboardLive
  # ...demais rotas
end
```

---

## 8. Bot do Telegram

### Passo 1 — Criar o bot no BotFather

1. Abrir Telegram → buscar `@BotFather`
2. Enviar `/newbot`
3. Nome amigável: ex. `Meu Financeiro`
4. Username (deve terminar em `bot`): ex. `meu_financeiro_bot`
5. Copiar o **token**: `123456789:AABBccDDeeFF...`

### Passo 2 — Registrar comandos no BotFather

`/setcommands` → escolher o bot → colar:
```
start - Boas-vindas e ajuda
saldo - Ver saldo de todas as contas
contas - Listar contas disponíveis
gasto - /gasto 50.90 alimentação almoço
receita - /receita 3000 salário conta-corrente
resumo - Resumo do mês atual
fatura - Fatura atual dos cartões
```

### Passo 3 — Variável de ambiente

```elixir
# config/runtime.exs
config :manager, :telegram_token, System.fetch_env!("TELEGRAM_BOT_TOKEN")
```

### Passo 4 — Configurar webhook

```bash
# Em dev: expor com ngrok
ngrok http 4000

# Registrar webhook
curl "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -d "url=https://SEU_DOMINIO/telegram/webhook/{TOKEN}"
```

### Comandos implementados

| Comando | Ação |
|---------|------|
| `/start` | Boas-vindas |
| `/saldo` | Saldo de todas as contas |
| `/contas` | Lista contas |
| `/gasto 50.90 alimentação almoço` | Lança despesa |
| `/receita 3000 salário conta-corrente` | Lança receita |
| `/resumo` | Resumo do mês (receitas vs despesas) |
| `/fatura` | Fatura atual dos cartões |

Resposta (confirmação simples):
```
✅ Gasto de R$ 45,50 em Alimentação registrado.
```

> O bot é **stateless**: aceita apenas comandos completos em uma linha.
> Sem sessão, sem fluxo multi-etapas, sem dados no banco sobre Telegram.

### Arquitetura do bot

```
lib/manager/telegram/
  bot.ex        # use ExGram.Bot
  handler.ex    # parse e despacha comandos para Finance contexts
  formatter.ex  # formata respostas em texto

lib/manager_web/controllers/
  telegram_controller.ex  # recebe webhook POST
```

Router:
```elixir
post "/telegram/webhook/:token", ManagerWeb.TelegramController, :webhook
```

---

## 9. Estrutura de Arquivos

```
lib/
  manager/
    application.ex
    repo.ex
    finance/
      accounts.ex
      credit_cards.ex
      transactions.ex
      categories.ex
      schemas/
        account.ex
        credit_card.ex
        credit_card_bill.ex
        transaction.ex
        category.ex
    telegram/
      bot.ex
      handler.ex
      formatter.ex
  manager_web/
    router.ex
    controllers/
      telegram_controller.ex
    live/
      dashboard_live.ex
      accounts_live/index.ex + show.ex
      credit_cards_live/index.ex + show.ex
      transactions_live/index.ex + new.ex
      categories_live/index.ex
      reports_live.ex
    components/
      layouts/
        root.html.heex   # data-theme="dark"
        app.html.heex    # sidebar nav

priv/repo/
  migrations/
    001_create_categories.exs
    002_create_accounts.exs
    003_create_credit_cards.exs
    004_create_credit_card_bills.exs
    005_create_transactions.exs
  seeds.exs
```

---

## 10. Ordem de Implementação

1. `mix phx.new` com SQLite
2. Adicionar dependências (`mix deps.get`)
3. `mix phx.gen.auth Accounts User users`
4. Criar migrations + `mix ecto.create && mix ecto.migrate`
5. Criar schemas Ecto com validações e associations
6. Criar contexts (`Finance.*`)
7. Configurar DaisyUI dark theme + `data-theme="dark"` no root layout
8. Montar layout base com sidebar de navegação
9. `DashboardLive`
10. `AccountsLive` (CRUD)
11. `CreditCardsLive` com ciclo de faturas
12. `TransactionsLive`
13. `CategoriesLive`
14. `ReportsLive` com Chart.js (CDN)
15. Criar bot no BotFather + configurar token
16. Implementar bot (`ex_gram`, handler, formatter)
17. Webhook no router
18. Seeds com categorias padrão

---

## 11. Verificação

```bash
mix phx.server
ngrok http 4000

# Registrar webhook
curl "https://api.telegram.org/bot{TOKEN}/setWebhook?url=https://xxxx.ngrok.io/telegram/webhook/{TOKEN}"

# Testar no Telegram
/saldo
/gasto 45.50 alimentação jantar fora
```

No browser:
- `/` → saldos atualizados
- `/transactions` → transação criada via bot na lista
- `/credit-cards/:id` → fatura OPEN com lançamentos
- `/reports` → gráficos do mês
