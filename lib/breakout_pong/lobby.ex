defmodule BreakoutPong.Lobby do
  def new do
    %{
      players: [],
    }
  end

  def put(lobby, playerName) do
    newPlayers = Map.get(lobby, :players) ++ [playerName]

    lobby
    |> Map.put(:players, newPlayers)
  end

  def client_view(lobby) do
    %{
      playerList: Map.get(lobby, :players)
    }
  end
end
