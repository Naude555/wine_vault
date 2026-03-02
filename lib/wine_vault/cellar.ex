defmodule WineVault.Cellar do
  import Ecto.Query, warn: false

  alias WineVault.Accounts.User
  alias WineVault.Cellar.{CellarEntry, ConsumptionEvent, DrinkWindow, Tag, Wine, WineReview}
  alias WineVault.Repo

  def list_wines do
    Repo.all(from wine in Wine, order_by: [asc: wine.winery, asc: wine.name, desc: wine.vintage])
  end

  def get_wine!(id), do: Repo.get!(Wine, id)

  def create_wine(attrs) do
    %Wine{}
    |> Wine.changeset(attrs)
    |> Repo.insert()
  end

  def list_cellar_entries_for_user(%User{id: user_id}) do
    Repo.all(
      from entry in CellarEntry,
        where: entry.user_id == ^user_id,
        preload: [:wine],
        order_by: [desc: entry.inserted_at]
    )
  end

  def create_cellar_entry(%User{id: user_id}, attrs) do
    %CellarEntry{user_id: user_id}
    |> CellarEntry.changeset(attrs)
    |> Repo.insert()
  end

  def list_drink_windows_for_user(%User{id: user_id}) do
    Repo.all(
      from drink_window in DrinkWindow,
        where: drink_window.user_id == ^user_id,
        preload: [:wine],
        order_by: [asc: drink_window.drink_from_year]
    )
  end

  def upsert_drink_window(%User{id: user_id}, attrs) do
    wine_id = Map.get(attrs, "wine_id") || Map.get(attrs, :wine_id)

    drink_window =
      Repo.get_by(DrinkWindow, user_id: user_id, wine_id: wine_id) || %DrinkWindow{user_id: user_id}

    drink_window
    |> DrinkWindow.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def create_review(%User{id: user_id}, attrs) do
    %WineReview{user_id: user_id}
    |> WineReview.changeset(attrs)
    |> Repo.insert()
  end

  def list_reviews_for_wine(wine_id) do
    Repo.all(
      from review in WineReview,
        where: review.wine_id == ^wine_id,
        preload: [:user],
        order_by: [desc: review.inserted_at]
    )
  end

  def review_summary_for_wine(wine_id) do
    Repo.one(
      from review in WineReview,
        where: review.wine_id == ^wine_id,
        select: %{average_rating: avg(review.rating), reviews_count: count(review.id)}
    )
  end

  def list_public_tags_for_wine(wine_id) do
    Repo.all(
      from tag in Tag,
        where: tag.wine_id == ^wine_id and tag.visibility == "public",
        order_by: [asc: tag.name]
    )
  end

  def list_private_tags_for_user(%User{id: user_id}) do
    Repo.all(
      from tag in Tag,
        where: tag.user_id == ^user_id and tag.visibility == "private",
        preload: [:wine],
        order_by: [asc: tag.name]
    )
  end

  def create_tag(%User{id: user_id}, attrs) do
    visibility = Map.get(attrs, "visibility") || Map.get(attrs, :visibility)

    tag =
      if visibility == "private" do
        %Tag{user_id: user_id}
      else
        %Tag{}
      end

    tag
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  def create_consumption_event(%User{id: user_id}, attrs) do
    %ConsumptionEvent{user_id: user_id}
    |> ConsumptionEvent.changeset(attrs)
    |> Repo.insert()
  end

  def dashboard_snapshot(%User{id: user_id}) do
    by_variety =
      Repo.all(
        from entry in CellarEntry,
          join: wine in assoc(entry, :wine),
          where: entry.user_id == ^user_id and not entry.is_consumed,
          group_by: wine.variety,
          select: {wine.variety, sum(entry.quantity)},
          order_by: [desc: sum(entry.quantity)]
      )

    aging_status =
      Repo.all(
        from drink_window in DrinkWindow,
          where: drink_window.user_id == ^user_id,
          select: %{
            wine_id: drink_window.wine_id,
            drink_from_year: drink_window.drink_from_year,
            drink_until_year: drink_window.drink_until_year
          }
      )

    low_stock =
      Repo.all(
        from entry in CellarEntry,
          where: entry.user_id == ^user_id and entry.quantity <= 2 and not entry.is_consumed,
          preload: [:wine],
          order_by: [asc: entry.quantity]
      )

    %{
      by_variety: by_variety,
      aging_status: aging_status,
      low_stock: low_stock,
      reviewed_wines_count: reviewed_wines_count(user_id),
      trending_wines: trending_wines()
    }
  end

  defp reviewed_wines_count(user_id) do
    Repo.one(
      from review in WineReview,
        where: review.user_id == ^user_id,
        select: count(fragment("distinct ?", review.wine_id))
    ) || 0
  end

  defp trending_wines do
    Repo.all(
      from review in WineReview,
        join: wine in assoc(review, :wine),
        group_by: [wine.id, wine.name, wine.winery, wine.vintage],
        order_by: [desc: count(review.id), desc: avg(review.rating)],
        limit: 5,
        select: %{
          wine_id: wine.id,
          label: fragment("? || ' ' || ? || ' (' || ? || ')'", wine.winery, wine.name, wine.vintage),
          reviews: count(review.id),
          avg_rating: avg(review.rating)
        }
    )
  end
end
