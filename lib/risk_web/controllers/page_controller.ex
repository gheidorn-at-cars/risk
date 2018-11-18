defmodule RiskWeb.PageController do
  use RiskWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
