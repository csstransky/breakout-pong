defmodule BreakoutPong.Game do
  def new do
    %{
      isLobby: true,
      lobbyList: [],
      player1: "",
      player2: "",
      ballx: 100,
      bally: 100,
      ballSpeed: 2,
      velx: 1,
      vely: 1,
      player1x: 670,
      player1y: 100,
      player2x: 10,
      player2y: 100,
      player1score: 0,
      player2score: 0,
      height: 600,
      width: 700,
      upArrow: 38,
      downArrow: 40,
      paddleHeight: 100,
      paddleWidth: 20,
      paddleSpeed: 5,
      ballSize: 10,
      loop: false,
    }
  end

  def client_view(game) do
    %{
      isLobby: game.isLobby,
      lobbyList: game.lobbyList,
      player1: game.player1,
      player2: game.player2,
      ballx: 100,
      bally: 100,
      ballSpeed: 2,
      velx: 1,
      vely: 1,
      player1x: 670,
      player1y: 100,
      player2x: 10,
      player2y: 100,
      player1score: 0,
      player2score: 0,
      height: 600,
      width: 700,
      upArrow: 38,
      downArrow: 40,
      paddleHeight: 100,
      paddleWidth: 20,
      paddleSpeed: 5,
      ballSize: 10,
      loop: false,
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
