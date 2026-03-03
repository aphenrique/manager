defmodule ManagerWeb.TelegramController do
  use ManagerWeb, :controller

  alias Manager.Telegram.Handler

  def webhook(conn, params) do
    expected_token = Application.get_env(:manager, :telegram_token)

    cond do
      is_nil(expected_token) or expected_token == "" ->
        send_resp(conn, 403, "forbidden")

      not Plug.Crypto.secure_compare(conn.params["token"] || "", expected_token) ->
        send_resp(conn, 403, "forbidden")

      not allowed_chat?(params) ->
        send_resp(conn, 200, "ok")

      true ->
        case Handler.handle(params) do
          {chat_id, text} when is_binary(text) ->
            ExGram.send_message(chat_id, text, parse_mode: "Markdown")

          _ ->
            :ok
        end

        send_resp(conn, 200, "ok")
    end
  end

  defp allowed_chat?(params) do
    case Application.get_env(:manager, :telegram_allowed_chat_id) do
      nil ->
        true

      allowed_id ->
        incoming_id = get_in(params, ["message", "chat", "id"])
        to_string(incoming_id) == to_string(allowed_id)
    end
  end
end
