defmodule Manager.Repo do
  use Ecto.Repo,
    otp_app: :manager,
    adapter: Ecto.Adapters.Postgres
end
