defmodule Manager.Repo.Migrations.AddIncomingTransferToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :incoming_transfer, :boolean, default: false, null: false
    end
  end
end
