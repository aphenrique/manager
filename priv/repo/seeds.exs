# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Manager.Repo.insert!(%Manager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
for cat <- [
      %{name: "Alimentação", icon: "🍔"},
      %{name: "Lazer", icon: "🛝"},
      %{name: "Moradia", icon: "🏠"},
      %{name: "Educação", icon: "📚"},
      %{name: "Vestuário", icon: "👚"},
      %{name: "Serviço", icon: "🛠️"},
      %{name: "Transporte", icon: "🚘"},
      %{name: "Conta", icon: "🧾"},
      %{name: "Saúde", icon: "🩺"},
      %{name: "Viagem", icon: "🧳"},
      %{name: "Música", icon: "🎸"}
    ] do
  {:ok, _} = Manager.Transactions.create_category(cat)
end

for sup <- [
      %{name: "Amazon"},
      %{name: "Mineirão"},
      %{name: "MAgazine Luiza"}
    ] do
  {:ok, _} = Manager.Transactions.create_supplier(sup)
end
