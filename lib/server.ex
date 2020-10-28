defmodule Rochambo.Server do
    use GenServer

    # Client API

    def start_link do
        GenServer.start(Rochambo.Server, [], name: RockPaperScissors)
    end

    def status() do
        state() |> Map.get(:status)
    end

    def state() do
        GenServer.call(RockPaperScissors, :state)
    end

    def join(player_name) do
        GenServer.call(RockPaperScissors, {:join, player_name})
    end

    def play(gambit) do
        GenServer.call(RockPaperScissors, {:play, gambit})
    end

    def scores do
        GenServer.call(RockPaperScissors, :get_scores)
    end

    def get_players do
        GenServer.call(RockPaperScissors, :get_players)
    end



    # Server API

    @impl true
    def init(_name) do
        initial_state = %{
            status: :need_players,
            winner: nil,
            players: [],
            choices: %{},
            scores: %{}
        }
        {:ok, initial_state}
    end

    @impl true
    def handle_call(:state, _from, game_state) do
        {:reply, game_state, game_state}
    end

    @impl true
    def handle_call(:get_players, _from, game_state) do
        {:reply, Enum.map(game_state.players, & &1[:name]), game_state}
    end

    @impl true
    def handle_call(:get_scores, _from, game_state) do
        {:reply, game_state.scores, game_state}
    end

    @impl true
    def handle_call({:join, player_name}, from, game_state) do
        {pid, _ref} = from
        case game_state.status do
            :need_players -> case pid in Enum.map(game_state.players, & &1[:id]) do
                true -> {:reply, {:error, "Already joined!"}, game_state}
                _ -> players = [%{id: pid, name: player_name} | game_state.players]
                    new_scores = Map.put(game_state.scores, player_name, 0)
                    new_choices = Map.put(game_state.choices, player_name, :none)
                    new_status = if (length(players) == 2), do: :waiting_for_gambits, else: :need_players
                    new_state = game_state 
                        |> Map.put(:players, players) 
                        |> Map.put(:scores, new_scores)
                        |> Map.put(:choices, new_choices)  
                        |> Map.put(:status, new_status)
                    {:reply, :joined, new_state}
                end
            _ -> {:reply, {:error, "Already full!"}, game_state}
        end
        
    end

    @impl true
    def handle_call({:play, gambit}, from, game_state) do
        {pid, _ref} = from
        player_name = Enum.find(game_state.players, fn player -> player.id === pid end).name
        new_choices = Map.put(game_state.choices, player_name, gambit)
        new_state = game_state
            |> Map.put(:choices, new_choices)
        case :none in Map.values(new_choices) do
            true -> {:noreply, new_state, :hibernate}
            _ -> set_winner = calculate_winner(new_state)
                message = cond do
                    set_winner.winner === :draw -> "draw"
                    set_winner.winner === player_name -> "you won!"
                    true -> "you lose!"
                end
                {:reply, message, set_winner}
        end        
    end

    defp calculate_winner(state) do
        [player_1, player_2] = Map.keys(state.choices)
        winner = case state.choices do
            %{^player_1 => :rock , ^player_2 => :paper} ->     player_2
            %{^player_1 => :rock , ^player_2 => :scissors} ->  player_1
      
            %{^player_1 => :paper , ^player_2 => :rock} ->     player_1
            %{^player_1 => :paper , ^player_2 => :scissors} -> player_2
      
            %{^player_1 => :scissors , ^player_2 => :rock} ->  player_2
            %{^player_1 => :scissors , ^player_2 => :paper} -> player_1
      
            _ ->  :draw
          end
          
          new_scores = update_score(winner, state)
          reset_gambits = for {k, _v} <- state.choices, into: %{}, do: {k, :none}
          %{state | winner: winner}
            |> Map.put(:scores, new_scores)
            |> Map.put(:choices, reset_gambits)
    end

    defp update_score(winner, state) do
        Map.put(state.scores, winner, state.scores[winner] + 1)
    end

end