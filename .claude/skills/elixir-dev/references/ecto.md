# Ecto Guidelines

## Queries e Associations

- **Always** preload Ecto associations in queries when they'll be accessed in templates
  - e.g., a message that needs `message.user.email` must preload `user`
- Remember `import Ecto.Query` and supporting modules when writing `seeds.exs`

## Schemas

- `Ecto.Schema` fields always use `:string` type, even for `:text` columns:
  - `field :name, :string`

## Changesets

- `Ecto.Changeset.validate_number/2` **does NOT support the `:allow_nil` option**
  - By default, Ecto validations only run if a change for the field exists and the value is not nil
- **Always** use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- **Never** use map access syntax on changesets (`changeset[:field]`)
- Fields set programmatically (e.g., `user_id`) must **not** be listed in `cast` calls — set them explicitly when creating the struct

## Migrations

- **Always** invoke `mix ecto.gen.migration migration_name_using_underscores` to generate migration files
  - This ensures correct timestamp and naming conventions

## Este Projeto

- Database: SQLite via `ecto_sqlite3`
- 5 tabelas: `categories`, `accounts`, `credit_cards`, `credit_card_bills`, `transactions`
- 4 contexts: `Finance.Accounts`, `Finance.CreditCards`, `Finance.Transactions`, `Finance.Categories`
- Account balance = `initial_balance + transactions` (calculated, not stored)
- Credit card uses bill cycles: `credit_card_bills` table with states `open → closed → paid`
