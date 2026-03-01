defmodule WineVaultWeb.PageController do
  use WineVaultWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
