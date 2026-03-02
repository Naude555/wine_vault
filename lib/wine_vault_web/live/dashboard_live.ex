defmodule WineVaultWeb.DashboardLive do
  use WineVaultWeb, :live_view

  alias WineVault.Cellar

  def mount(_params, _session, socket) do
    snapshot = Cellar.dashboard_snapshot(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:snapshot, snapshot)}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={%{}}>
      <section class="space-y-8">
        <div>
          <h1 class="text-3xl font-semibold">Dashboard Insights</h1>
          <p class="text-zinc-600 mt-2">Private cellar analytics with public market pulse.</p>
        </div>

        <div class="grid gap-4 md:grid-cols-2">
          <article class="rounded-2xl border border-zinc-200 p-5">
            <h2 class="font-semibold">Bottles by variety (private)</h2>
            <ul class="mt-2 space-y-1 text-sm">
              <li :for={{variety, count} <- @snapshot.by_variety}>{variety}: {count}</li>
            </ul>
          </article>

          <article class="rounded-2xl border border-zinc-200 p-5">
            <h2 class="font-semibold">Low stock alerts (private)</h2>
            <ul class="mt-2 space-y-1 text-sm">
              <li :for={entry <- @snapshot.low_stock}>{entry.wine.name} — {entry.quantity} left</li>
            </ul>
          </article>
        </div>

        <div class="grid gap-4 md:grid-cols-2">
          <article class="rounded-2xl border border-zinc-200 p-5">
            <h2 class="font-semibold">Wines you reviewed (public contribution)</h2>
            <p class="mt-2 text-4xl font-bold">{@snapshot.reviewed_wines_count}</p>
          </article>

          <article class="rounded-2xl border border-zinc-200 p-5">
            <h2 class="font-semibold">Trending wines (public)</h2>
            <ul class="mt-2 space-y-1 text-sm">
              <li :for={wine <- @snapshot.trending_wines}>
                {wine.label} — {wine.reviews} reviews · {Float.round(wine.avg_rating || 0.0, 1)} ★
              </li>
            </ul>
          </article>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
