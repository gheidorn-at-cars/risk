defmodule Risk.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """

  use GenServer

  require Logger

  @timeout :timer.hours(2)

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_name) do
    GenServer.start_link(
      __MODULE__,
      {game_name},
      name: via_tuple(game_name)
    )
  end

  @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_name) do
    {:via, Registry, {Risk.GameRegistry, game_name}}
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  def game_state(game_name) do
    GenServer.call(via_tuple(game_name), :game_state)
  end

  def start_game(server, players) do
    GenServer.call(server, {:start_game, players})
  end

  ## Server Callbacks

  def init({game_name}) do
    game =
      case :ets.lookup(:games_table, game_name) do
        [] ->
          game = Risk.Game.new()
          :ets.insert(:games_table, {game_name, game})
          game

        [{^game_name, game}] ->
          game
      end

    Logger.info("Spawned game server process named '#{game_name}'.")

    {:ok, game, @timeout}
  end

  def handle_call({:start_game, players}, _from, state) do
    if(length(players) != 2) do
      {:reply, :invalid_start_players, state}
    else
      new_state = %{status: :game_started, players: players, map: %{}}
      {:reply, :success, new_state}
    end
  end

  def handle_call(:game_state, _from, state) do
    {:reply, state, state}
  end
end
