defmodule RiskWeb.Router do
  use RiskWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, {RiskWeb.LayoutView, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RiskWeb do
    pipe_through :browser

    get "/", PageController, :index
    live("/games/new", GameLive.New)
    live("/games/board/:game_name", GameLive.Board)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RiskWeb do
  #   pipe_through :api
  # end
end
