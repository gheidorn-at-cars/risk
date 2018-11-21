# Risk

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Install Node.js dependencies with `cd assets && npm install`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Run Tests

`mix test`

## Game Engine

You can test some of the Game Engine features in an IEX session. To start a game between two dummy players ("Player1" and "Player2"):

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
  phase: "ArmyPlacement",
  turn: "Player1",
  winner: nil,
  players: [
    %Player{
      name: "Player1",
      armies_to_place: 10
    },
    %Player{
      name: "Player2",
      armies_to_place: 10
    }
  ],
  board: {
    continents: [],
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
    ]
  }
}
```

When a Game starts, the Board is created. Then, some number of Territories are randomly assigned to each player - an even amount to each. Each Player takes turns placing an army on a Territory they own. When each Player has finished, the game shifts phases (TODO - Next Phase).

```
iex> {:ok, state} = Risk.GameServer.place_army("ww3", "Alberta", "Player 1", 1)
```

This should update the `Risk.Game` state to reflect that:

- Alberta now has 1 army in it,
- "Player 1" has 1 fewer army to place (from 10 to 9), and
- `turn` should switch to "Player 2"

Let's place an army for Player 2.

```
iex> {:ok, state} = Risk.GameServer.place_army("ww3", "Ontario", "Player 2", 1)
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
