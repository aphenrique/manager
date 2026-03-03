defmodule Mix.Tasks.Manager.CreateUser do
  @shortdoc "Creates a user with email and password"
  @moduledoc """
  Creates a user account with email and password.

      mix manager.create_user EMAIL PASSWORD

  The password must be at least 12 characters.
  """

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run([email, password]) do
    case Manager.Accounts.register_user(%{email: email, password: password}) do
      {:ok, user} ->
        Mix.shell().info("User created: #{user.email}")

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        Mix.shell().error("Failed to create user:")

        Enum.each(errors, fn {field, msgs} ->
          Mix.shell().error("  #{field}: #{Enum.join(msgs, ", ")}")
        end)

        exit({:shutdown, 1})
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix manager.create_user EMAIL PASSWORD")
    exit({:shutdown, 1})
  end
end
