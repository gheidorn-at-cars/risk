defmodule RiskWeb.GameLive.New do
  use Phoenix.LiveView

  alias Risk.GameState
  alias RiskWeb.Router.Helpers, as: Routes

  def mount(_values, socket) do
    {:ok,
     assign(socket, %{
       count: "",
       changeset: GameState.changeset(%{}),
       game: %GameState{}
     })}
  end

  def render(assigns), do: RiskWeb.GameView.render("new.html", assigns)

  def handle_event("save", %{"game_state" => params}, socket) do
    IO.inspect("### $$$$ ##### SAVE")

    case Risk.GameSupervisor.start_game(params["name"]) do
      {:ok, _pid} ->
        {:stop,
         socket
         |> put_flash(:info, "New Game started with the name " <> params["name"])
         |> redirect(to: Routes.live_path(socket, RiskWeb.GameLive.Board, params["name"]))}

      {:error, {:already_started, _pid}} ->
        {:noreply,
         socket
         #  |> put_flash(:error, "A game by that name already exists.  Please choose another game.")
         |> assign(%{
           count: "A game by that name already exists.  Please choose another game.",
           changeset: GameState.changeset(%{}),
           game: %GameState{}
         })}

      {:error, :failed_to_persist_game} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to persist to database...game#" <> params["name"])
         |> assign(%{
           count: "CRUNCH",
           changeset: GameState.changeset(%{}),
           game: %GameState{}
         })}

        # {:error, %Ecto.Changeset{} = changeset} ->
        #   {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"name" => params}, socket) do
    IO.inspect("### $$$$ ##### VALIDATE")
    IO.inspect(params)

    {:noreply,
     assign(socket, %{
       count: "validating...",
       changeset: GameState.changeset(%{}),
       game: %GameState{}
     })}
  end

  def handle_event("game_status", _value, socket) do
    # look up the game server
    Risk.GameServer.via_tuple("www")
    |> IO.inspect()

    # do the deploy process
    {:noreply,
     assign(socket, %{
       count: 42,
       changeset: GameState.changeset(%{}),
       game: %GameState{}
     })}
  end
end
