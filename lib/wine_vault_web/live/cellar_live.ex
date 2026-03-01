defmodule WineVaultWeb.CellarLive do
  use WineVaultWeb, :live_view

  alias WineVault.Cellar

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:page_title, "My Cellar")
      |> assign(:entries, Cellar.list_cellar_entries_for_user(user))
      |> assign(:wines, Cellar.list_wines())
      |> assign(:form, to_form(%{"wine_id" => "", "quantity" => 1, "storage_location" => "", "acquisition_type" => ""}, as: :entry))

    {:ok, socket}
  end

  def handle_event("add_entry", %{"entry" => attrs}, socket) do
    user = socket.assigns.current_user

    case Cellar.create_cellar_entry(user, attrs) do
      {:ok, _entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Bottle added to your private cellar")
         |> assign(:entries, Cellar.list_cellar_entries_for_user(user))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :entry))}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={nil}>
      <section class="space-y-8">
        <div>
          <h1 class="text-3xl font-semibold tracking-tight">My Cellar</h1>
          <p class="text-zinc-600 mt-2">Private inventory, gift metadata, and personal memories.</p>
        </div>

        <.form for={@form} id="cellar-entry-form" phx-submit="add_entry" class="grid gap-3 rounded-2xl border border-zinc-200 p-5 shadow-sm transition hover:shadow-md">
          <.input type="select" field={@form[:wine_id]} label="Wine" options={Enum.map(@wines, &{"#{&1.winery} #{&1.name} (#{&1.vintage})", &1.id})} />
          <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
            <.input type="number" field={@form[:quantity]} label="Quantity" />
            <.input type="text" field={@form[:storage_location]} label="Storage location" />
          </div>
          <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
            <.input type="text" field={@form[:acquisition_type]} label="Acquisition type" />
            <.input type="text" field={@form[:gifted_by]} label="Gifted by" />
          </div>
          <.input type="text" field={@form[:gifted_occasion]} label="Gifted occasion" />
          <.input type="textarea" field={@form[:personal_notes]} label="Private notes" />
          <button id="save-cellar-entry" class="rounded-xl bg-zinc-900 px-4 py-2 text-white transition hover:bg-zinc-700">Save cellar entry</button>
        </.form>

        <div class="overflow-hidden rounded-2xl border border-zinc-200 bg-white">
          <table class="min-w-full text-sm">
            <thead class="bg-zinc-50 text-zinc-600">
              <tr>
                <th class="px-4 py-3 text-left">Wine</th>
                <th class="px-4 py-3 text-left">Qty</th>
                <th class="px-4 py-3 text-left">Location</th>
                <th class="px-4 py-3 text-left">Gift</th>
                <th class="px-4 py-3 text-left">Private notes</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={entry <- @entries} id={"entry-#{entry.id}"} class="border-t border-zinc-100 hover:bg-zinc-50 transition">
                <td class="px-4 py-3">{entry.wine.winery} {entry.wine.name} ({entry.wine.vintage})</td>
                <td class="px-4 py-3">{entry.quantity}</td>
                <td class="px-4 py-3">{entry.storage_location}</td>
                <td class="px-4 py-3">{entry.gifted_by} {entry.gifted_occasion}</td>
                <td class="px-4 py-3">{entry.personal_notes}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
