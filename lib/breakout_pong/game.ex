defmodule BreakoutPong.Game do
  def new do
    %{
      isLobby: false,
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
    x = %{
      isLobby: Map.get(game, :isLobby),
      lobbyList: Map.get(game, :lobbyList),
      player1: Map.get(game, :player1),
      player2: Map.get(game, :player2),
      ballx: Map.get(game, :ballx),
      bally: Map.get(game, :bally),
      ballSpeed: Map.get(game, :ballSpeed),
      velx: Map.get(game, :velx),
      vely: Map.get(game, :vely),
      player1x: Map.get(game, :player1x),
      player1y: Map.get(game, :player1y),
      player2x: Map.get(game, :player2x),
      player2y: Map.get(game, :player2y),
      player1score: Map.get(game, :player1score),
      player2score: Map.get(game, :player2score),
      height: Map.get(game, :height),
      width: Map.get(game, :width),
      upArrow: Map.get(game, :upArrow),
      downArrow: Map.get(game, :downArrow),
      paddleHeight: Map.get(game, :paddleHeight),
      paddleWidth: Map.get(game, :paddleWidth),
      paddleSpeed: Map.get(game, :paddleSpeed),
      ballSize: Map.get(game, :ballSize),
      loop: Map.get(game, :loop),
    }
    x
  end

  def key_pressed(game, key, player) do
    if player = Map.get(game, :player1) do
      x = Map.get(game, :player1y)
      if key == "up" do
        Map.put(game, :player1y, x + 20)
      else
        Map.put(game, :player1y, x - 20)
      end
    end

    if player = Map.get(game, :player2) do
      x = Map.get(game, :player2y)
      if key == "down" do
        Map.put(game, :player2y, x + 20)
      else
        Map.put(game, :player2y, x - 20)
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
