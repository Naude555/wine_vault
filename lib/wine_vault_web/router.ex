defmodule WineVaultWeb.Router do
  use WineVaultWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {WineVaultWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WineVaultWeb do
    pipe_through :browser

    live_session :default, on_mount: [{WineVaultWeb.UserContext, :default}] do
      live "/", HomeLive
      live "/cellar", CellarLive
      live "/aging-planner", AgingPlannerLive
      live "/dashboard", DashboardLive
      live "/wines/:id", WineLiveShow
    end
  end

  if Application.compile_env(:wine_vault, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WineVaultWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
