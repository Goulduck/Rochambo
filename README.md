# Rochambo

## Issues

Having issues with second game in tests. Gambit has been reset but timeout occurs. I believe this is either because it's resetting after the Task has played it's second gambit, or it is not sending the initial loss message to the Task so no second gambit is being received but I'm unable to work out why currently.

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
