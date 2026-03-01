defmodule WineVault.Cellar.ConsumptionEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "consumption_events" do
    field :consumed_on, :date
    field :occasion, :string
    field :people_present, :string
    field :publish_review, :boolean, default: false

    belongs_to :cellar_entry, WineVault.Cellar.CellarEntry
    belongs_to :wine, WineVault.Cellar.Wine
    belongs_to :user, WineVault.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:cellar_entry_id, :wine_id, :consumed_on, :occasion, :people_present, :publish_review])
    |> validate_required([:cellar_entry_id, :wine_id, :consumed_on])
  end
end
