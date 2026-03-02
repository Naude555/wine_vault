defmodule WineVault.Cellar.Wine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wines" do
    field :name, :string
    field :winery, :string
    field :variety, :string
    field :vintage, :integer
    field :region, :string

    has_many :cellar_entries, WineVault.Cellar.CellarEntry
    has_many :reviews, WineVault.Cellar.WineReview
    has_many :tags, WineVault.Cellar.Tag

    timestamps(type: :utc_datetime)
  end

  def changeset(wine, attrs) do
    wine
    |> cast(attrs, [:name, :winery, :variety, :vintage, :region])
    |> validate_required([:name, :winery, :variety, :vintage, :region])
    |> validate_number(:vintage, greater_than: 1900, less_than: 2100)
    |> unique_constraint([:name, :winery, :vintage])
  end
end
