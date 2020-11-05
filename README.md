# Rochambo

## To-Dos

Would like to implement tests for the calculate_winner function.

Gambits can be played before 2 players have joined. This needs fixing.

## Overview

A GenServer that can play Rock, Paper, Scissors.

```elixir
alias Rochambo.Server

def go() do
  Server.status()
  # ... :need_players

  Server.join(name)
  # ... :joined

  Server.play(:rock)
  # ... "Player X played :scissors! You won!"

  Server.scores() 
  # ... %{"bob" => 1, "michael" => 0}

  Server.players()
  # ... ["bob", "michael"]
end
```
