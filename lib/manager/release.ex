defmodule Manager.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :manager

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def create_user(email, password) do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(Manager.Repo, fn _repo ->
        case Manager.Accounts.register_user(%{email: email, password: password}) do
          {:ok, user} ->
            IO.puts("User created: #{user.email}")

          {:error, changeset} ->
            errors =
              Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
                Enum.reduce(opts, msg, fn {key, value}, acc ->
                  String.replace(acc, "%{#{key}}", to_string(value))
                end)
              end)

            IO.puts("Failed to create user:")

            Enum.each(errors, fn {field, msgs} ->
              IO.puts("  #{field}: #{Enum.join(msgs, ", ")}")
            end)
        end
      end)
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    # Many platforms require SSL when connecting to the database
    Application.ensure_all_started(:ssl)
    Application.ensure_loaded(@app)
  end
end
