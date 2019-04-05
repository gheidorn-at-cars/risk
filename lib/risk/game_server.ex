defmodule Risk.GameServer do
  @moduledoc """
  A game server process that holds a `Game` struct as its state.
  """

  use GenServer

  require Logger

  alias Risk.Game

  @timeout :timer.hours(2)

  # Client (Public) Interface

  @doc """
  Spawns a new game server process registered under the given `game_name`.
  """
  def start_link(game_name, players) do
    Logger.info("###> inside #{__MODULE__}.start_link(#{game_name}, #{inspect(players)})")

    case GenServer.start_link(
           __MODULE__,
           {game_name, players},
           name: via_tuple(game_name)
         ) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, reason} ->
        Logger.error(reason)
    end
  end

  @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  def via_tuple(game_name) do
    Logger.info("###> inside #{__MODULE__}.via_tuple(#{game_name})")
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

  @doc """
  Returns the `Game` (state) of the game server process registered under the given `game_name`.
  """
  def game_state(game_name) do
    GenServer.call(via_tuple(game_name), :game_state)
  end

  def turn(game_name) do
    GenServer.call(via_tuple(game_name), :turn)
  end

  @doc """
  Calls `GameServer.player_territories`.
  """
  def player_territories(game_name, player) do
    GenServer.call(via_tuple(game_name), {:player_territories, player})
  end

  def place_armies(game_name, territory_name, player, num_armies) do
    GenServer.call(via_tuple(game_name), {:place_armies, territory_name, player, num_armies})
  end

  def start_game(server, players) do
    GenServer.call(server, {:start_game, players})
  end

  ## Server Callbacks

  def init({game_name, players}) do
    Logger.info("###> inside #{__MODULE__}.init(#{game_name})")

    game =
      case :ets.lookup(:games_table, game_name) do
        [] ->
          game = Game.new(game_name, players)
          :ets.insert(:games_table, {game_name, game})
          game

        [{^game_name, game}] ->
          game
      end

    Logger.info(
      "Spawned game server process named '#{game_name}' with players #{inspect(players)}."
    )

    case Risk.GameState.create(game) do
      {:ok, _} ->
        {:ok, game, @timeout}

      {:error, changeset} ->
        Logger.error("creating game state failed!")
        Logger.error("#{changeset}")
    end
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
    {:reply, {:ok, state}, state}
  end

  def handle_call(:turn, _from, state) do
    {:reply, {:ok, Game.get_player_by_turn(state) |> elem(0)}, state}
  end

  def handle_call({:player_territories, player}, _from, state) do
    {:reply, {:ok, Game.player_territories(state.territories, player)}, state}
  end

  def handle_call(
        {:place_armies, territory_name, player, num_armies},
        _from,
        state
      ) do
    case Game.place_armies(state, territory_name, player, num_armies) do
      {:ok, state} ->
        {_next_player_turn, state} = Game.advance_turn(state)
        {:reply, {:ok, state}, state}

      {:error, :territory_not_owned} ->
        {:reply, {:error, :territory_not_owned}, state}

      {:error, :not_enough_armies} ->
        {:reply, {:error, :not_enough_armies}, state}
    end
  end
end
