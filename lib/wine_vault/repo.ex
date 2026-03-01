defmodule WineVault.Repo do
  use Ecto.Repo,
    otp_app: :wine_vault,
    adapter: Ecto.Adapters.Postgres
end
