# Risk

Currenty, work is focused on the Game Engine. There is no real UI at this time. In the future, we will look at implementing the Game Client in ELM and Phoenix.

## Game Engine

The Game Engine supports the following parts of the game:

- Initialization of the Game State and Player States
- Random Distribution of Territories to Players
-

## Taking the Game Engine for a spin...

You can test some of the Game Engine features in an IEX session.

### Start a New Game

To start a game between two dummy players ("Player1" and "Player2"):

```
iex> {:ok, pid} = Risk.GameSupervisor.start_game("ww3")
[info] Spawned game server process named 'www3'.
```

This will start an instance of `GameServer` and return the `pid`. You can then use the `pid` to issue commands to the `GameServer`. Let's check the state of the Game:

```
iex> {:ok, state} = Risk.GameServer.game_state("ww3")
```

This functon looks at the registry for the GameServer with the associated `pid` and returns the state.

```
%Risk.Game{
  game_settings: %{"starting_armies" => 7},
  players: [
    %Risk.Player{armies: 7, name: "Player 2"},
    %Risk.Player{armies: 7, name: "Player 1"}
  ],
  territories: [
    %Risk.Board.Territory{
      adjacent: ["Alaska", "Northwest Territory", "Western United States",
        "Ontario", "Greenland"],
      armies: nil,
      continent: "North America",
      name: "Alberta",
      owner: nil
    },
    ...
  ],
  state: "Initialized",
  turn: "Player1",
  turn_order: ["Player 1", "Player 2"],
  winner: nil,
}
```

### Placing Armies

When a Game starts, some number of Territories are randomly assigned to each player - an even amount to each. Each Player takes turns placing an army on a Territory they own. When each Player has finished, the game shifts phases (TODO - Next Phase).

First, determine whose turn it is.

```
iex> {:ok, player} = Risk.GameServer.turn("ww3")
{:ok, %Risk.Player{armies: 7, name: "Player 1"}}
```

Go ahead and place armies for that player in the Alberta territory.

```
iex> {:ok, state} = Risk.GameServer.place_armies("ww3", "Alberta", player, 1)
```

If the player owns the territory, the `Risk.Game` state to reflect that:

- Alberta now has 1 army in it,
- "Player 1" has 1 fewer army to place (from 7 to 6), and
- `turn` should switch to the other player

Let's place an army for the next player.

```
iex> {:ok, player} = Risk.GameServer.turn("ww3")
{:ok, %Risk.Player{armies: 7, name: "Player 2"}}
iex> {:ok, state} = Risk.GameServer.place_armies("ww3", "Ontario", player, 1)
```

Continue to do this until all armies are placed. Once each Player is out of armies, then subsequent messages to place armies should return an error. The error depends on the state of the command.

```
iex> {:ok, state} = Risk.GameServer.place_army("ww3", "Ontario", "Player 2", 1)
{:error, :invalid_command, "There are no more armies for that Player to place."}
```

or

```
{:error, :invalid_command, "Cannot place armies during this Phase:  PlayerTurn_EarnArmies."}
```

Now that initial army placement has occurred, we move onto the first player turn. Each Player turn has steps:

- Earn Armies
- Place Earned Armies
- Attacking
- Free Movement
