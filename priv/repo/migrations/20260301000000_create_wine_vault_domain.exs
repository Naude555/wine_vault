defmodule WineVault.Repo.Migrations.CreateWineVaultDomain do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    create table(:wines) do
      add :name, :string, null: false
      add :winery, :string, null: false
      add :variety, :string, null: false
      add :vintage, :integer, null: false
      add :region, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:wines, [:name, :winery, :vintage])

    create table(:cellar_entries) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :quantity, :integer, null: false, default: 1
      add :storage_location, :string
      add :acquisition_type, :string
      add :gifted_by, :string
      add :gifted_occasion, :string
      add :personal_notes, :text
      add :personal_tasting_notes, :text
      add :memory_notes, :text
      add :occasion_notes, :text
      add :is_consumed, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cellar_entries, [:user_id])
    create index(:cellar_entries, [:wine_id])

    create table(:drink_windows) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :drink_from_year, :integer
      add :peak_year, :integer
      add :drink_until_year, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:drink_windows, [:user_id])
    create index(:drink_windows, [:wine_id])
    create unique_index(:drink_windows, [:user_id, :wine_id])

    create table(:wine_reviews) do
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :rating, :integer, null: false
      add :review_text, :text
      add :tasting_notes, :text
      add :consumed_year, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:wine_reviews, [:wine_id])
    create index(:wine_reviews, [:user_id])

    create table(:consumption_events) do
      add :cellar_entry_id, references(:cellar_entries, on_delete: :delete_all), null: false
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :consumed_on, :date, null: false
      add :occasion, :string
      add :people_present, :string
      add :publish_review, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:consumption_events, [:user_id])
    create index(:consumption_events, [:wine_id])

    create table(:tags) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :wine_id, references(:wines, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :visibility, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tags, [:wine_id])
    create index(:tags, [:user_id])
  end
end
