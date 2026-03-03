# Manager — Gestão Financeira Pessoal

App de gestão financeira pessoal construído com Phoenix LiveView, SQLite e integração com bot do Telegram.

---

## Requisitos

- Elixir 1.19+ / OTP 28+
- Node.js (para assets)

---

## Rodando o servidor

### 1. Instalar dependências

```bash
mix deps.get
mix assets.setup
```

### 2. Criar o banco e rodar as migrations

```bash
mix ecto.create
mix ecto.migrate
```

### 3. Popular as categorias padrão

```bash
mix run priv/repo/seeds.exs
```

### 4. Iniciar o servidor

```bash
mix phx.server
```

Acesse [http://localhost:4000](http://localhost:4000) no browser.

Na primeira vez, crie uma conta em `/users/register`.

---

## Integrando o bot do Telegram

O bot é **stateless** — aceita apenas comandos completos em uma linha. Nenhum dado do Telegram é armazenado no banco.

### Passo 1 — Criar o bot no BotFather

1. Abra o Telegram e busque por `@BotFather`
2. Envie `/newbot`
3. Escolha um nome amigável: ex. `Financeiro Pessoal`
4. Escolha um username (deve terminar em `bot`): ex. `financeiro_pessoal_bot`
5. O BotFather devolverá o **token** do bot — guarde-o

### Passo 2 — Registrar os comandos no BotFather

Envie `/setcommands` para o BotFather, selecione o bot e cole o bloco abaixo:

```
start - Boas-vindas e ajuda
saldo - Ver saldo de todas as contas
contas - Listar contas disponíveis
cartoes - Listar cartões de crédito
gasto - /gasto 50.90 alimentação almoço [destino]
receita - /receita 3000 salário mensal [conta]
resumo - Resumo de receitas e gastos do mês
fatura - Fatura atual dos cartões de crédito
```

### Passo 3 — Configurar a variável de ambiente

```bash
export TELEGRAM_BOT_TOKEN="123456789:AABBccDDeeFFggHHiiJJkkLLmmNNooPPqq"
```

### Passo 4 — Expor o servidor localmente (desenvolvimento)

O Telegram exige um endpoint HTTPS público para o webhook. Em desenvolvimento, use o [ngrok](https://ngrok.com):

```bash
ngrok http 4000
```

Anote a URL gerada, ex: `https://abc123.ngrok-free.app`

### Passo 5 — Iniciar o servidor com o token

```bash
TELEGRAM_BOT_TOKEN="seu_token_aqui" mix phx.server
```

### Passo 6 — Registrar o webhook no Telegram

Substitua `{TOKEN}` pelo token do bot e `{URL}` pela URL do ngrok:

```bash
curl "https://api.telegram.org/bot{TOKEN}/setWebhook" \
  -d "url=https://{URL}/telegram/webhook/{TOKEN}"
```

Resposta esperada:

```json
{"ok": true, "description": "Webhook was set"}
```

### Passo 7 — Testar no Telegram

Abra a conversa com o bot e envie:

```
/saldo
/contas
/cartoes
/gasto 45.50 alimentação jantar fora
/gasto 45.50 alimentação jantar fora nubank
/receita 3000 salário mensal
/receita 3000 salário mensal bradesco
/resumo
```

---

## Comandos disponíveis no bot

| Comando | Descrição |
|---------|-----------|
| `/start` ou `/help` | Exibe ajuda e lista de comandos |
| `/saldo` | Saldo atual de todas as contas |
| `/contas` | Lista as contas cadastradas |
| `/cartoes` | Lista os cartões de crédito |
| `/gasto <valor> <categoria> <descrição> [destino]` | Registra uma despesa |
| `/receita <valor> <descrição> [conta]` | Registra uma receita |
| `/resumo` | Resumo de receitas e gastos do mês |
| `/fatura` | Fatura aberta de cada cartão |

### Destino nos comandos `/gasto` e `/receita`

O último argumento é opcional e identifica **onde lançar** a transação (busca parcial por nome):

```
# Gasto na primeira conta cadastrada (fallback)
/gasto 45.50 alimentação almoço

# Gasto em conta bancária específica
/gasto 45.50 alimentação almoço bradesco

# Gasto em cartão de crédito
/gasto 45.50 alimentação almoço nubank

# Receita na primeira conta (fallback)
/receita 3000 salário mensal

# Receita em conta específica
/receita 3000 salário mensal bradesco
```

> A busca é parcial e case-insensitive — `nub` encontra "Nubank", `brad` encontra "Bradesco".
> Use `/contas` e `/cartoes` para ver os nomes exatos cadastrados.

---

## Variáveis de ambiente

| Variável | Descrição | Obrigatória |
|----------|-----------|-------------|
| `TELEGRAM_BOT_TOKEN` | Token do bot gerado pelo BotFather | Não (bot desabilitado sem ela) |
| `DATABASE_PATH` | Caminho do arquivo SQLite (produção) | Só em produção |
| `SECRET_KEY_BASE` | Chave de segurança do Phoenix (produção) | Só em produção |
| `PHX_HOST` | Hostname público (produção) | Só em produção |
| `PORT` | Porta do servidor (padrão: 4000) | Não |
