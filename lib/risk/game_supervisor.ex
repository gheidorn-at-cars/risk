defmodule Risk.GameSupervisor do
  @moduledoc """
  A supervisor that starts `GameServer` processes dynamically.
  """

  use DynamicSupervisor
  alias Risk.Game
  alias Risk.GameServer

  require Logger

  def start_link(_arg) do
    Logger.info("###> inside #{__MODULE__}.start_link(_arg)")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Logger.info("###> inside #{__MODULE__}.init(:ok)")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Starts a `GameServer` process and supervises it.
  """
  def start_game(game_name, players) do
    Logger.info("###> inside #{__MODULE__}.start_game(#{game_name})")

    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [game_name, players]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, child} ->
        {:ok, child}

      {:error, reason} ->
        Logger.info("###> DynamicSupervisor.start_child failed!")
        Logger.error("#{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Terminates the `GameServer` process normally. It won't be restarted.
  """
  def stop_game(game_name) do
    :ets.delete(:games_table, game_name)

    child_pid = GameServer.game_pid(game_name)
    DynamicSupervisor.terminate_child(__MODULE__, child_pid)
  end

  def list_children() do
    list_keys(:games_table, [])
  end

  def list_keys(table_name, acc) when length(acc) == 0 do
    case :ets.first(table_name) do
      :"$end_of_table" ->
        acc

      key ->
        list_keys(table_name, [key | acc])
    end
  end

  def list_keys(table_name, acc) do
    case :ets.next(table_name, hd(acc)) do
      :"$end_of_table" ->
        acc

      key ->
        list_keys(table_name, [key | acc])
    end
  end
end
