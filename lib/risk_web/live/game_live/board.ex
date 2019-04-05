defmodule RiskWeb.GameLive.Board do
  use Phoenix.LiveView

  alias Risk.GameState

  def mount(params, socket) do
    IO.inspect("GameLive.Board MOUNTING")
    IO.inspect(params)

    IO.inspect(Risk.GameState.list_game_states())

    {:ok, assign(socket, %{name: params["name"], state: params["state"]})}
  end

  def render(assigns), do: RiskWeb.GameView.render("board.html", assigns)

  def handle_event("game_status", _value, socket) do
    IO.inspect("GameLive.Board GAME_STATUS")

    # do the deploy process
    {:noreply,
     assign(socket, %{
       count: "game status!",
       changeset: GameState.changeset(%{}),
       game: %GameState{}
     })}
  end

  def handle_event("game", game, socket) do
    IO.inspect("GameLive.Board GAME")
    {:noreply, assign(socket, %{game: game})}
  end

  def handle_event("place_armies", game, socket) do
    IO.inspect("GameLive.Board PLACE ARMIES")
    {:noreply, assign(socket, %{game: game})}
  end

  def handle_event("order_attack", game, socket) do
    IO.inspect("GameLive.Board ORDER ATTACK")
    {:noreply, assign(socket, %{game: game})}
  end

  def handle_event("end_turn", game, socket) do
    IO.inspect("GameLive.Board END TURN")
    {:noreply, assign(socket, %{game: game})}
  end
end
