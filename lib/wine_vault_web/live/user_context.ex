defmodule WineVaultWeb.UserContext do
  import Phoenix.Component

  alias WineVault.Accounts

  def on_mount(:default, _params, _session, socket) do
    user = Accounts.ensure_demo_user!()
    {:cont, assign(socket, :current_user, user)}
  end
end
