defmodule WineVaultWeb.WineLiveShow do
  use WineVaultWeb, :live_view

  alias WineVault.Cellar

  def mount(%{"id" => id}, _session, socket) do
    wine = Cellar.get_wine!(id)
    summary = Cellar.review_summary_for_wine(wine.id)

    {:ok,
     socket
     |> assign(:page_title, "Wine")
     |> assign(:wine, wine)
     |> assign(:summary, summary)
     |> assign(:reviews, Cellar.list_reviews_for_wine(wine.id))
     |> assign(:public_tags, Cellar.list_public_tags_for_wine(wine.id))
     |> assign(:form, to_form(%{"wine_id" => wine.id, "rating" => "", "review_text" => "", "tasting_notes" => "", "consumed_year" => ""}, as: :review))}
  end

  def handle_event("save_review", %{"review" => attrs}, socket) do
    case Cellar.create_review(socket.assigns.current_user, attrs) do
      {:ok, _review} ->
        wine_id = socket.assigns.wine.id
        summary = Cellar.review_summary_for_wine(wine_id)

        {:noreply,
         socket
         |> put_flash(:info, "Public review posted")
         |> assign(:summary, summary)
         |> assign(:reviews, Cellar.list_reviews_for_wine(wine_id))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :review))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={%{}}>
      <section class="space-y-8">
        <div class="rounded-2xl border border-zinc-200 p-6 bg-gradient-to-br from-rose-50 to-white">
          <h1 class="text-3xl font-semibold">{@wine.winery} {@wine.name} ({@wine.vintage})</h1>
          <p class="mt-1 text-zinc-600">{@wine.variety} · {@wine.region}</p>
          <div class="mt-4 flex gap-6 text-sm">
            <p>Average rating: <span class="font-semibold">{Float.round(@summary.average_rating || 0.0, 1)} ★</span></p>
            <p>Review count: <span class="font-semibold">{@summary.reviews_count}</span></p>
          </div>
        </div>

        <.form for={@form} id="wine-review-form" phx-submit="save_review" class="grid gap-3 rounded-2xl border border-zinc-200 p-5">
          <.input type="number" field={@form[:rating]} label="Rating (1-5)" min="1" max="5" />
          <.input type="number" field={@form[:consumed_year]} label="Consumed year" />
          <.input type="textarea" field={@form[:review_text]} label="Public review" />
          <.input type="textarea" field={@form[:tasting_notes]} label="Public tasting notes" />
          <button id="save-review" class="rounded-xl bg-emerald-700 px-4 py-2 text-white transition hover:bg-emerald-600">Publish review</button>
        </.form>

        <div class="space-y-3">
          <h2 class="text-xl font-semibold">Public review feed</h2>
          <article :for={review <- @reviews} id={"review-#{review.id}"} class="rounded-xl border border-zinc-200 p-4">
            <p class="text-sm text-zinc-500">{review.user.name} · {review.rating} ★</p>
            <p class="mt-2">{review.review_text}</p>
            <p class="mt-2 text-sm text-zinc-600">{review.tasting_notes}</p>
          </article>
        </div>

        <div>
          <h2 class="text-xl font-semibold">Flavor tags</h2>
          <div class="mt-2 flex flex-wrap gap-2">
            <span :for={tag <- @public_tags} class="rounded-full bg-zinc-100 px-3 py-1 text-xs font-medium text-zinc-700">{tag.name}</span>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
