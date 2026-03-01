alias WineVault.Accounts
alias WineVault.Cellar

_ = Accounts.ensure_demo_user!()

sample_wines = [
  %{name: "Cabernet Sauvignon", winery: "Kanonkop", variety: "Cabernet Sauvignon", vintage: 2018, region: "Stellenbosch"},
  %{name: "Barolo Cannubi", winery: "Marchesi di Barolo", variety: "Nebbiolo", vintage: 2019, region: "Piedmont"},
  %{name: "Nuits-Saint-Georges", winery: "Domaine Faiveley", variety: "Pinot Noir", vintage: 2020, region: "Burgundy"}
]

Enum.each(sample_wines, fn attrs ->
  case Cellar.create_wine(attrs) do
    {:ok, _wine} -> :ok
    {:error, _changeset} -> :ok
  end
end)
