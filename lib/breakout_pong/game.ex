defmodule BreakoutPong.Game do
  def new do
    %{
      isLobby: true,
      lobbyList: [],
      player1: "",
      player2: "",
      word: next_word(),
      guesses: [],
    }
  end

  def client_view(game) do
    ws = String.graphemes(game.word)
    gs = game.guesses
    %{
      isLobby: game.isLobby,
      lobbyList: game.lobbyList,
      player1: game.player1,
      player2: game.player2,
      skel: skeleton(ws, gs),
      goods: Enum.filter(gs, &(Enum.member?(ws, &1))),
      bads: Enum.filter(gs, &(!Enum.member?(ws, &1))),
      max: max_guesses(),
    }
  end

  def start_game(game) do
    ## TODO Find out how to get length of list
    if List.length(game.lobbyList) >= 2 do
      player1 = game.lobbyList[0]
      player2 = game.lobbyList[1]
      #TODO Actually make the new lobby List
      newLobbyList = []
      game
      |> Map.put(:player1, player1)
      |> Map.put(:player2, player2)
      |> Map.put(:lobbyList, newLobbyList)
    else
      game
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
