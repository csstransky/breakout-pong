defmodule BreakoutPong.Game do
  def new do
    %{
      isLobby: true,
      lobbyList: [],
      player1: "",
      player2: "",
      ballx: 100,
      bally: 100,
      player1x: 670,
      player1y: 100,
      player2x: 10,
      player2y: 10,
      player1score: 0,
      player2score: 0,
    }
  end

  def client_view(game) do
    %{
      isLobby: game.isLobby,
      lobbyList: game.lobbyList,
      player1: game.player1,
      player2: game.player2,
      ballx: Map.get(game, :ballx),
      bally: Map.get(game, :bally),
      player1x: Map.get(game, :player1x),
      player1y: Map.get(game, :player1y),
      player2x: Map.get(game, :player2x),
      player2y: Map.get(game, :player2y),
      player1score: Map.get(game, :player1score),
      player2score: Map.get(game, :player2score),
    }
  end

  def start_game(game) do
    if length(game.lobbyList) >= 2 do
      [player1 | popList] = game.lobbyList
      [player2 | newLobbyList] = popList
      game
      |> Map.put(:player1, player1)
      |> Map.put(:player2, player2)
      |> Map.put(:lobbyList, newLobbyList)
      |> Map.put(:isLobby, false)
    else
      # TODO This is strictly for debugging and will have to be removed at some
      # point before deployment, hence the awkward else if statement
      if length(game.lobbyList) == 1 do
        [player1 | newLobbyList] = game.lobbyList
        game
        |> Map.put(:player1, player1)
        |> Map.put(:lobbyList, newLobbyList)
        |> Map.put(:isLobby, false)
      else
        game
      end
    end
  end

  # TODO: keypress won't work until the player variables in the state are set after leaving lobby
  def key_pressed(game, key, player) do
    IO.inspect(player)

    if player == Map.get(game, :player1) do
      IO.inspect("player 1 triggered")
      x = Map.get(game, :player1y)
      if key == "up" do
        Map.put(game, :player1y, x + 30)
      else
        Map.put(game, :player1y, x - 30)
      end
    end

    if player == Map.get(game, :player2) do
      IO.inspect("player 2 triggered")
      x = Map.get(game, :player2y)
      if key == "down" do
        Map.put(game, :player2y, x + 30)
      else
        Map.put(game, :player2y, x - 30)
      end
    end
  end

  # TODO: this is the function that should be called after leaving lobby to set player and state variables.  We can also use this to restart the game if we re-initialize everything else
  def initialize_game(game) do
    Map.put(game,:isLobby, false) # mark as game, not lobby
    Map.put(Game, :player1, Enum.at(Map.get(game, :lobbyList), 0)) # save the players, in order they joined
    Map.put(Game, :player2, Enum.at(Map.get(game, :lobbyList), 1)) # save the players, in order they joined

  end

  def add_to_lobby(game, player) do
    if Enum.member?(game.lobbyList, player) do
      game
    else
      game
      |> Map.put(:lobbyList, game.lobbyList ++ [player])
    end
  end

  def remove_from_lobby(game, player) do
    if Enum.member?(game.lobbyList, player) do
      game
      |> Map.put(:lobbyList, game.lobbyList ++ [player])
    else
      game
    end
  end


  ################ Old functions below #######################

  def skeleton(word, guesses) do
    Enum.map word, fn cc ->
      if Enum.member?(guesses, cc) do
        cc
      else
        "_"
      end
    end
  end

  def guess(game, letter) do
    if letter == "z" do
      raise "That's not a real letter"
    end

    gs = game.guesses
    |> MapSet.new()
    |> MapSet.put(letter)
    |> MapSet.to_list

    Map.put(game, :guesses, gs)
  end

  def max_guesses do
    10
  end

  def next_word do
    words = ~w(
      horse snake jazz violin
      muffin cookie pizza sandwich
      house train clock
      parsnip marshmallow
    )
    Enum.random(words)
  end

end
