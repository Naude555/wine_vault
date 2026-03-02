defmodule WineVaultWeb.PageControllerTest do
  use WineVaultWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "WineVault SaaS"
  end
end
