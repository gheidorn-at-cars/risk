defmodule RiskWeb.PageController do
  use RiskWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    render(conn, "index.html")
    # LiveView.Controller.live_render(conn, RiskWeb.GameView, session: %{})
  end
end
