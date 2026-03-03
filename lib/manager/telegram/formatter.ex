defmodule Manager.Telegram.Formatter do
  alias Manager.Finance.{Accounts, CreditCards, Transactions}

  def saldo do
    accounts = Accounts.list_accounts_with_balance()

    if Enum.empty?(accounts) do
      "Nenhuma conta cadastrada. Acesse o app para criar suas contas."
    else
      lines =
        Enum.map(accounts, fn a ->
          "• #{a.name}: #{format_currency(a.balance)}"
        end)

      "💰 *Saldos das contas:*\n\n" <> Enum.join(lines, "\n")
    end
  end

  def contas do
    accounts = Accounts.list_accounts()

    if Enum.empty?(accounts) do
      "Nenhuma conta cadastrada."
    else
      lines = Enum.map(accounts, fn a -> "• #{a.name} (#{a.type})" end)
      "🏦 *Contas disponíveis:*\n\n" <> Enum.join(lines, "\n")
    end
  end

  def cartoes do
    cards = CreditCards.list_credit_cards()

    if Enum.empty?(cards) do
      "Nenhum cartão cadastrado."
    else
      lines = Enum.map(cards, fn c -> "• #{c.name} (fecha dia #{c.closing_day})" end)
      "💳 *Cartões disponíveis:*\n\n" <> Enum.join(lines, "\n")
    end
  end

  def resumo do
    today = Date.utc_today()
    summary = Transactions.monthly_summary(today.year, today.month)
    resultado = Decimal.sub(summary.income, summary.expense)

    emoji = if Decimal.compare(resultado, 0) == :lt, do: "🔴", else: "🟢"

    """
    📊 *Resumo de #{month_name(today.month)} #{today.year}:*

    ✅ Receitas: #{format_currency(summary.income)}
    ❌ Despesas: #{format_currency(summary.expense)}
    #{emoji} Resultado: #{format_currency(resultado)}
    """
  end

  def fatura do
    cards = CreditCards.list_credit_cards()

    if Enum.empty?(cards) do
      "Nenhum cartão cadastrado."
    else
      lines =
        Enum.map(cards, fn card ->
          balance = CreditCards.current_balance(card)
          "• #{card.name}: #{format_currency(balance)} (fecha dia #{card.closing_day})"
        end)

      "💳 *Faturas abertas:*\n\n" <> Enum.join(lines, "\n")
    end
  end

  def gasto_registrado(description, amount, category_name, dest_name) do
    cat = if category_name, do: " em #{category_name}", else: ""
    "✅ *#{format_currency(amount)}#{cat}* lançado em #{dest_name}.\n_#{description}_"
  end

  def receita_registrada(description, amount, account_name) do
    "✅ *#{format_currency(amount)}* creditado em #{account_name}.\n_#{description}_"
  end

  def ajuda do
    """
    💰 *Financeiro Bot* — comandos disponíveis:

    /saldo — Saldo de todas as contas
    /contas — Listar contas disponíveis
    /cartoes — Listar cartões de crédito
    /gasto <valor> <categoria> <descrição> [<destino>] — Lançar despesa
    /receita <valor> <descrição> [<conta>] — Lançar receita
    /resumo — Resumo do mês atual
    /fatura — Faturas abertas dos cartões

    *Exemplos:*
    `/gasto 45.50 alimentação almoço` — lança na primeira conta
    `/gasto 45.50 alimentação almoço nubank` — lança no cartão Nubank
    `/receita 3000 salário mensal bradesco` — lança na conta Bradesco
    """
  end

  def erro_formato_gasto do
    """
    ❌ Formato inválido. Use:
    `/gasto <valor> <categoria> <descrição> [<destino>]`

    *Exemplos:*
    `/gasto 45.50 alimentação almoço`
    `/gasto 45.50 alimentação almoço nubank`
    """
  end

  def erro_formato_receita do
    """
    ❌ Formato inválido. Use:
    `/receita <valor> <descrição> [<conta>]`

    *Exemplos:*
    `/receita 3000 salário mensal`
    `/receita 3000 salário mensal bradesco`
    """
  end

  def erro_conta_nao_encontrada(nome) do
    "❌ Conta '#{nome}' não encontrada. Use /contas para ver as disponíveis."
  end

  defp format_currency(amount) when is_nil(amount), do: "R$ 0,00"

  defp format_currency(amount) do
    value = Decimal.to_float(amount)
    abs_value = abs(value)
    sign = if value < 0, do: "-", else: ""
    formatted = :erlang.float_to_binary(abs_value, decimals: 2)
    [integer_part, decimal_part] = String.split(formatted, ".")

    integer_with_sep =
      integer_part
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.chunk_every(3)
      |> Enum.join(".")
      |> String.graphemes()
      |> Enum.reverse()
      |> Enum.join()

    "#{sign}R$ #{integer_with_sep},#{decimal_part}"
  end

  defp month_name(1), do: "Janeiro"
  defp month_name(2), do: "Fevereiro"
  defp month_name(3), do: "Março"
  defp month_name(4), do: "Abril"
  defp month_name(5), do: "Maio"
  defp month_name(6), do: "Junho"
  defp month_name(7), do: "Julho"
  defp month_name(8), do: "Agosto"
  defp month_name(9), do: "Setembro"
  defp month_name(10), do: "Outubro"
  defp month_name(11), do: "Novembro"
  defp month_name(12), do: "Dezembro"
end
