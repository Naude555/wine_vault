defmodule WineVault.Cellar.WineReview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wine_reviews" do
    field :rating, :integer
    field :review_text, :string
    field :tasting_notes, :string
    field :consumed_year, :integer

    belongs_to :wine, WineVault.Cellar.Wine
    belongs_to :user, WineVault.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def changeset(review, attrs) do
    review
    |> cast(attrs, [:wine_id, :rating, :review_text, :tasting_notes, :consumed_year])
    |> validate_required([:wine_id, :rating])
    |> validate_number(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:consumed_year, greater_than: 1900, less_than: 2100)
  end
end
