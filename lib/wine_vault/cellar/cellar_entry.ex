defmodule WineVault.Cellar.CellarEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cellar_entries" do
    field :quantity, :integer
    field :storage_location, :string
    field :acquisition_type, :string
    field :gifted_by, :string
    field :gifted_occasion, :string
    field :personal_notes, :string
    field :personal_tasting_notes, :string
    field :memory_notes, :string
    field :occasion_notes, :string
    field :is_consumed, :boolean, default: false

    belongs_to :user, WineVault.Accounts.User
    belongs_to :wine, WineVault.Cellar.Wine
    has_many :consumption_events, WineVault.Cellar.ConsumptionEvent

    timestamps(type: :utc_datetime)
  end

  def changeset(cellar_entry, attrs) do
    cellar_entry
    |> cast(attrs, [
      :wine_id,
      :quantity,
      :storage_location,
      :acquisition_type,
      :gifted_by,
      :gifted_occasion,
      :personal_notes,
      :personal_tasting_notes,
      :memory_notes,
      :occasion_notes,
      :is_consumed
    ])
    |> validate_required([:wine_id, :quantity])
    |> validate_number(:quantity, greater_than: 0)
    |> foreign_key_constraint(:wine_id)
  end
end
