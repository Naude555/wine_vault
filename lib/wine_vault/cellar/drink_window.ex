defmodule WineVault.Cellar.DrinkWindow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drink_windows" do
    field :drink_from_year, :integer
    field :peak_year, :integer
    field :drink_until_year, :integer

    belongs_to :user, WineVault.Accounts.User
    belongs_to :wine, WineVault.Cellar.Wine

    timestamps(type: :utc_datetime)
  end

  def changeset(drink_window, attrs) do
    drink_window
    |> cast(attrs, [:wine_id, :drink_from_year, :peak_year, :drink_until_year])
    |> validate_required([:wine_id])
    |> validate_number(:drink_from_year, greater_than: 1900, less_than: 2100)
    |> validate_number(:peak_year, greater_than: 1900, less_than: 2100)
    |> validate_number(:drink_until_year, greater_than: 1900, less_than: 2100)
    |> unique_constraint([:user_id, :wine_id])
  end
end
