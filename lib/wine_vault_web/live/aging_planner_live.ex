defmodule WineVaultWeb.AgingPlannerLive do
  use WineVaultWeb, :live_view

  alias WineVault.Cellar

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:page_title, "Aging Planner")
     |> assign(:drink_windows, Cellar.list_drink_windows_for_user(user))
     |> assign(:wines, Cellar.list_wines())
     |> assign(:form, to_form(%{"wine_id" => "", "drink_from_year" => "", "peak_year" => "", "drink_until_year" => ""}, as: :drink_window))}
  end

  def handle_event("save_window", %{"drink_window" => attrs}, socket) do
    user = socket.assigns.current_user

    case Cellar.upsert_drink_window(user, attrs) do
      {:ok, _window} ->
        {:noreply,
         socket
         |> put_flash(:info, "Private drink window saved")
         |> assign(:drink_windows, Cellar.list_drink_windows_for_user(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :drink_window))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={nil}>
      <section class="space-y-8">
        <div>
          <h1 class="text-3xl font-semibold">Aging Planner</h1>
          <p class="mt-2 text-zinc-600">Track private drink windows by wine identity.</p>
        </div>

        <.form for={@form} id="drink-window-form" phx-submit="save_window" class="grid gap-3 rounded-2xl border border-zinc-200 p-5">
          <.input type="select" field={@form[:wine_id]} label="Wine" options={Enum.map(@wines, &{"#{&1.winery} #{&1.name} (#{&1.vintage})", &1.id})} />
          <div class="grid grid-cols-1 gap-3 md:grid-cols-3">
            <.input type="number" field={@form[:drink_from_year]} label="Drink from" />
            <.input type="number" field={@form[:peak_year]} label="Peak year" />
            <.input type="number" field={@form[:drink_until_year]} label="Drink until" />
          </div>
          <button id="save-drink-window" class="rounded-xl bg-rose-700 px-4 py-2 text-white transition hover:bg-rose-600">Save window</button>
        </.form>

        <div class="grid gap-3">
          <article :for={window <- @drink_windows} id={"drink-window-#{window.id}"} class="rounded-xl border border-zinc-200 p-4">
            <h2 class="font-semibold">{window.wine.winery} {window.wine.name} ({window.wine.vintage})</h2>
            <p class="text-sm text-zinc-600">{window.drink_from_year} → {window.peak_year} → {window.drink_until_year}</p>
          </article>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
