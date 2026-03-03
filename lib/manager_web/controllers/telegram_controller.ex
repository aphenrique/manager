defmodule ManagerWeb.TelegramController do
  use ManagerWeb, :controller

  alias Manager.Telegram.Handler

  def webhook(conn, params) do
    expected_token = Application.get_env(:manager, :telegram_token, "")

    if conn.params["token"] == expected_token and expected_token != "" do
      case Handler.handle(params) do
        {chat_id, text} when is_binary(text) ->
          ExGram.send_message(chat_id, text, parse_mode: "Markdown")

        _ ->
          :ok
      end
    end

    send_resp(conn, 200, "ok")
  end
end
