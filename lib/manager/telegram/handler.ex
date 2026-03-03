defmodule Manager.Telegram.Handler do
  @moduledoc """
  Processa mensagens recebidas do Telegram.
  O bot é stateless — aceita apenas comandos completos em uma linha.

  Formato dos comandos:
    /gasto <valor> <categoria> <descrição> [<conta-ou-cartão>]
    /receita <valor> <descrição> [<conta>]

  O último argumento é opcionalmente o nome da conta ou cartão (busca parcial).
  Se omitido, o gasto vai para a primeira conta cadastrada.
  """

  alias Manager.Finance.{Accounts, CreditCards, Transactions, Categories}
  alias Manager.Telegram.Formatter

  def handle(%{"message" => %{"text" => text, "chat" => %{"id" => chat_id}}}) do
    text = String.trim(text)
    response = dispatch(text)
    {chat_id, response}
  end

  def handle(_update), do: nil

  defp dispatch("/start" <> _), do: Formatter.ajuda()
  defp dispatch("/help" <> _), do: Formatter.ajuda()
  defp dispatch("/saldo"), do: Formatter.saldo()
  defp dispatch("/contas"), do: Formatter.contas()
  defp dispatch("/cartoes"), do: Formatter.cartoes()
  defp dispatch("/resumo"), do: Formatter.resumo()
  defp dispatch("/fatura"), do: Formatter.fatura()

  defp dispatch("/gasto " <> args), do: handle_gasto(String.split(args, " ", parts: 3))
  defp dispatch("/gasto"), do: Formatter.erro_formato_gasto()

  defp dispatch("/receita " <> args), do: handle_receita(String.split(args, " ", parts: 2))
  defp dispatch("/receita"), do: Formatter.erro_formato_receita()

  defp dispatch(_), do: Formatter.ajuda()

  # /gasto <valor> <categoria> [<descrição> [<conta-ou-cartão>]]
  defp handle_gasto([amount_str, category_name | rest]) do
    raw = List.first(rest) || category_name
    {description, dest_result} = resolve_destination(raw)

    with {:ok, amount} <- parse_amount(amount_str),
         category when not is_nil(category) <- find_category(category_name),
         {:ok, dest_type, dest} <- dest_result do
      attrs =
        %{
          description: description,
          amount: amount,
          type: "expense",
          date: Date.utc_today(),
          category_id: category.id
        }
        |> put_destination(dest_type, dest)

      case Transactions.create_transaction(attrs) do
        {:ok, _} -> Formatter.gasto_registrado(description, amount, category.name, dest.name)
        {:error, _} -> "❌ Erro ao registrar o gasto. Tente novamente."
      end
    else
      :invalid_amount -> "❌ Valor inválido: #{amount_str}. Use ex: 45.50"
      :no_account -> "❌ Nenhuma conta encontrada. Crie uma conta no app primeiro."
      nil -> "❌ Categoria '#{category_name}' não encontrada. Use /contas para ver as disponíveis."
    end
  end

  defp handle_gasto(_), do: Formatter.erro_formato_gasto()

  # /receita <valor> [<descrição> [<conta>]]
  defp handle_receita([amount_str, rest_text]) do
    {description, dest_result} = resolve_account(rest_text)

    with {:ok, amount} <- parse_amount(amount_str),
         {:ok, account} <- dest_result do
      category =
        find_category("salário") || find_category("receita") || find_category("outras receitas")

      case Transactions.create_transaction(%{
             description: description,
             amount: amount,
             type: "income",
             date: Date.utc_today(),
             account_id: account.id,
             category_id: if(category, do: category.id, else: nil)
           }) do
        {:ok, _} -> Formatter.receita_registrada(description, amount, account.name)
        {:error, _} -> "❌ Erro ao registrar a receita. Tente novamente."
      end
    else
      :invalid_amount -> "❌ Valor inválido: #{amount_str}. Use ex: 3000"
      :no_account -> "❌ Nenhuma conta encontrada. Crie uma conta no app primeiro."
    end
  end

  defp handle_receita([amount_str]), do: handle_receita([amount_str, ""])
  defp handle_receita(_), do: Formatter.erro_formato_receita()

  # Resolve o último argumento do texto como conta bancária ou cartão de crédito.
  # Retorna {description, {:ok, :account | :credit_card, struct} | :no_account}
  defp resolve_destination("") do
    case first_account() do
      :no_account -> {"", :no_account}
      account -> {"", {:ok, :account, account}}
    end
  end

  defp resolve_destination(text) do
    words = String.split(text)
    last = List.last(words)
    prefix = words |> Enum.drop(-1) |> Enum.join(" ")

    cond do
      account = find_account(last) ->
        desc = if prefix == "", do: text, else: prefix
        {desc, {:ok, :account, account}}

      card = find_credit_card(last) ->
        desc = if prefix == "", do: text, else: prefix
        {desc, {:ok, :credit_card, card}}

      true ->
        case first_account() do
          :no_account -> {text, :no_account}
          account -> {text, {:ok, :account, account}}
        end
    end
  end

  # Igual ao resolve_destination, mas aceita apenas contas (para receitas).
  # Retorna {description, {:ok, account} | :no_account}
  defp resolve_account("") do
    case first_account() do
      :no_account -> {"", :no_account}
      account -> {"", {:ok, account}}
    end
  end

  defp resolve_account(text) do
    words = String.split(text)
    last = List.last(words)
    prefix = words |> Enum.drop(-1) |> Enum.join(" ")

    case find_account(last) do
      nil ->
        case first_account() do
          :no_account -> {text, :no_account}
          account -> {text, {:ok, account}}
        end

      account ->
        desc = if prefix == "", do: text, else: prefix
        {desc, {:ok, account}}
    end
  end

  defp put_destination(attrs, :account, dest), do: Map.put(attrs, :account_id, dest.id)
  defp put_destination(attrs, :credit_card, dest), do: Map.put(attrs, :credit_card_id, dest.id)

  @max_amount Decimal.new("99999999.99")

  defp parse_amount(str) do
    str = String.replace(str, ",", ".")

    case Decimal.parse(str) do
      {decimal, ""} ->
        cond do
          Decimal.compare(decimal, Decimal.new(0)) != :gt -> :invalid_amount
          Decimal.compare(decimal, @max_amount) == :gt -> :invalid_amount
          true -> {:ok, decimal}
        end

      _ ->
        :invalid_amount
    end
  end

  defp find_category(name) do
    name_lower = String.downcase(name)
    categories = Categories.list_categories()
    Enum.find(categories, fn c -> String.downcase(c.name) |> String.contains?(name_lower) end)
  end

  defp find_account(name) do
    name_lower = String.downcase(name)
    accounts = Accounts.list_accounts()
    Enum.find(accounts, fn a -> String.downcase(a.name) |> String.contains?(name_lower) end)
  end

  defp find_credit_card(name) do
    name_lower = String.downcase(name)
    cards = CreditCards.list_credit_cards()
    Enum.find(cards, fn c -> String.downcase(c.name) |> String.contains?(name_lower) end)
  end

  defp first_account do
    case Accounts.list_accounts() do
      [account | _] -> account
      [] -> :no_account
    end
  end
end
