defmodule WineVaultWeb.HomeLive do
  use WineVaultWeb, :live_view

  alias WineVault.Cellar

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "WineVault")
     |> assign(:wines, Cellar.list_wines())
     |> assign(:form, to_form(%{"name" => "", "winery" => "", "variety" => "", "vintage" => "", "region" => ""}, as: :wine))}
  end

  def handle_event("create_wine", %{"wine" => attrs}, socket) do
    case Cellar.create_wine(attrs) do
      {:ok, _wine} ->
        {:noreply,
         socket
         |> put_flash(:info, "Wine identity added to global catalog")
         |> assign(:wines, Cellar.list_wines())}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :wine))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={nil}>
      <section class="space-y-10">
        <div class="rounded-3xl border border-zinc-200 bg-gradient-to-br from-zinc-900 to-zinc-700 p-8 text-white">
          <h1 class="text-4xl font-semibold">WineVault SaaS</h1>
          <p class="mt-3 max-w-2xl text-zinc-200">
            Hybrid architecture: private cellar intelligence and public Vivino-style reviews.
          </p>
          <div class="mt-6 flex flex-wrap gap-3">
            <.link navigate={~p"/cellar"} class="rounded-xl bg-white/20 px-4 py-2 text-sm font-semibold transition hover:bg-white/30">My Cellar</.link>
            <.link navigate={~p"/aging-planner"} class="rounded-xl bg-white/20 px-4 py-2 text-sm font-semibold transition hover:bg-white/30">Aging Planner</.link>
            <.link navigate={~p"/dashboard"} class="rounded-xl bg-white/20 px-4 py-2 text-sm font-semibold transition hover:bg-white/30">Dashboard</.link>
          </div>
        </div>

        <div class="grid gap-8 lg:grid-cols-2">
          <.form for={@form} id="wine-form" phx-submit="create_wine" class="space-y-3 rounded-2xl border border-zinc-200 p-5 shadow-sm">
            <h2 class="text-xl font-semibold">Create wine identity (global)</h2>
            <.input field={@form[:name]} type="text" label="Name" />
            <.input field={@form[:winery]} type="text" label="Winery" />
            <div class="grid gap-3 md:grid-cols-2">
              <.input field={@form[:variety]} type="text" label="Variety" />
              <.input field={@form[:vintage]} type="number" label="Vintage" />
            </div>
            <.input field={@form[:region]} type="text" label="Region" />
            <button id="create-wine" class="rounded-xl bg-zinc-900 px-4 py-2 text-white transition hover:bg-zinc-700">Save wine</button>
          </.form>

          <div class="rounded-2xl border border-zinc-200 p-5">
            <h2 class="text-xl font-semibold">Public wine pages</h2>
            <ul class="mt-4 space-y-2 text-sm">
              <li :for={wine <- @wines}>
                <.link navigate={~p"/wines/#{wine.id}"} class="group flex items-center justify-between rounded-lg border border-zinc-100 px-3 py-2 transition hover:border-zinc-300 hover:bg-zinc-50">
                  <span>{wine.winery} {wine.name} ({wine.vintage})</span>
                  <.icon name="hero-arrow-right" class="size-4 text-zinc-400 transition group-hover:text-zinc-700" />
                </.link>
              </li>
            </ul>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
