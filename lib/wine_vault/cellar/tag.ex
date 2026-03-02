defmodule WineVault.Cellar.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @visibilities ["private", "public"]

  schema "tags" do
    field :name, :string
    field :visibility, :string

    belongs_to :user, WineVault.Accounts.User
    belongs_to :wine, WineVault.Cellar.Wine

    timestamps(type: :utc_datetime)
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:wine_id, :name, :visibility])
    |> validate_required([:wine_id, :name, :visibility])
    |> validate_inclusion(:visibility, @visibilities)
  end
end
