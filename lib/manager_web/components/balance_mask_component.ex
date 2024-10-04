defmodule ManagerWeb.BalanceMaskComponent do
  use Phoenix.Component

  def balance_mask(assigns) do
    ~H"""
    <span class="balance-mask">
      <%= format_balance(@balance) %>
    </span>
    """
  end

  defp format_balance(balance) when is_integer(balance) do
    balance
    |> Kernel./(100)
    |> :erlang.float_to_binary([decimals: 2])
  end

  defp format_balance(_), do: "0.00"
end
