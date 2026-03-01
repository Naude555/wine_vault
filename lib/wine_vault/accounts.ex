defmodule WineVault.Accounts do
  import Ecto.Query, warn: false

  alias WineVault.Accounts.User
  alias WineVault.Repo

  def ensure_demo_user! do
    Repo.get_by(User, email: "demo@winevault.local") ||
      %User{}
      |> User.changeset(%{email: "demo@winevault.local", name: "Demo Collector"})
      |> Repo.insert!()
  end
end
