# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Manager.Finance.Categories

categories = [
  # Despesas
  %{name: "Alimentação", color: "#f97316", icon: "cake", type: "expense"},
  %{name: "Transporte", color: "#3b82f6", icon: "truck", type: "expense"},
  %{name: "Moradia", color: "#8b5cf6", icon: "home", type: "expense"},
  %{name: "Saúde", color: "#ef4444", icon: "heart", type: "expense"},
  %{name: "Educação", color: "#06b6d4", icon: "academic-cap", type: "expense"},
  %{name: "Lazer", color: "#ec4899", icon: "face-smile", type: "expense"},
  %{name: "Vestuário", color: "#a855f7", icon: "shopping-bag", type: "expense"},
  %{name: "Assinaturas", color: "#64748b", icon: "tv", type: "expense"},
  %{name: "Outros gastos", color: "#6b7280", icon: "tag", type: "expense"},
  # Receitas
  %{name: "Salário", color: "#22c55e", icon: "banknotes", type: "income"},
  %{name: "Freelance", color: "#16a34a", icon: "computer-desktop", type: "income"},
  %{name: "Investimentos", color: "#15803d", icon: "chart-bar", type: "income"},
  %{name: "Outras receitas", color: "#4ade80", icon: "plus-circle", type: "income"}
]

Enum.each(categories, fn attrs ->
  case Categories.create_category(attrs) do
    {:ok, _} -> IO.puts("Categoria criada: #{attrs.name}")
    {:error, _} -> IO.puts("Categoria já existe: #{attrs.name}")
  end
end)

IO.puts("\nSeeds concluídos!")
