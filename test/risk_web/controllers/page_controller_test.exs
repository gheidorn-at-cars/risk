defmodule RiskWeb.PageControllerTest do
  use RiskWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Original Risk Board Game"
  end
end
