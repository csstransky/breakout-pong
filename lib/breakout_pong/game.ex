defmodule BreakoutPong.Game do
  #Width of paddle 20
  #Height of paddle 110
  #Ball radius 8
  def constants do
    %{
      paddleWidth: 20,
      paddleHeight: 110,
      ballRadius: 8,
      goalScoreEnemyPoints: 10,
      goalScoreSelfPoints: -5,
      blockPoints: 1,
    }
  end

  def new do
    %{
      isLobby: true,
      lobbyList: [],
      player1: "",
      player2: "",
      ball1x: 100,
      ball1y: 100,
      ball1SpeedX: 20,
      ball1SpeedY: 20,
      ball2x: 200,
      ball2y: 200,
      ball2SpeedX: 20,
      ball2SpeedY: 20,
      player1x: 10,
      player1y: 10,
      player2x: 670,
      player2y: 100,
      player1score: 0,
      player2score: 0,
      windowHeight: 600,
      windowWidth: 800,
    }
  end

  def reset_positions(game) do
    game
    |> Map.put(:ball1x, new().ball1x)
    |> Map.put(:ball1y, new().ball1y)
    |> Map.put(:ball1SpeedX, new().ball1SpeedX)
    |> Map.put(:ball1SpeedY, new().ball1SpeedY)
    |> Map.put(:ball2x, new().ball2x)
    |> Map.put(:ball2y, new().ball2y)
    |> Map.put(:ball2SpeedX, new().ball2SpeedX)
    |> Map.put(:ball2SpeedY, new().ball2SpeedY)
    |> Map.put(:player1x, new().player1x)
    |> Map.put(:player1y, new().player1y)
    |> Map.put(:player2x, new().player2x)
    |> Map.put(:player2y, new().player2y)
  end

  def client_view(game) do
    %{
      #TODO, this is a giant mess that will have to be fixed
      isLobby: game.isLobby,
      lobbyList: game.lobbyList,
      player1: game.player1,
      player2: game.player2,
      ball1x: game.ball1x,
      ball1y: game.ball1y,
      ball2x: game.ball2x,
      ball2y: game.ball2y,
      player1x: Map.get(game, :player1x),
      player1y: Map.get(game, :player1y),
      player2x: Map.get(game, :player2x),
      player2y: Map.get(game, :player2y),
      player1score: Map.get(game, :player1score),
      player2score: Map.get(game, :player2score),
      windowWidth: Map.get(game, :windowWidth),
      windowHeight: Map.get(game, :windowHeight),
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

  def move_balls(game) do
    if ballHitGoal?(game) do
      game
      |> set_goal_score()
      |> reset_positions()
    else
      game
      |> move_player_ball(1)
      |> move_player_ball(2)
    end
  end

  def ballHitGoal?(game) do
    game.ball1x > game.windowWidth
    || game.ball1x < 0
    || game.ball2x > game.windowWidth
    || game.ball2x < 0
  end

  def move_player_ball(game, playerNum) do
    tempBall = fn (game, playerNum) ->
        if playerNum == 1 do
          %{
            x: game.ball1x + game.ball1SpeedX,
            y: game.ball1y + game.ball1SpeedY,
            speedX: game.ball1SpeedX,
            speedY: game.ball1SpeedY,
          }
        else
          %{
            x: game.ball2x + game.ball2SpeedX,
            y: game.ball2y + game.ball2SpeedY,
            speedX: game.ball2SpeedX,
            speedY: game.ball2SpeedY,
          }
        end
      end

    cond do
      ballHitFloorOrCeiling?(game, tempBall) ->
        IO.puts "ball hit cieling"
        tempBall = tempBall
        |> Map.put(:speedY, -1 * tempBall.speedY)
        # TODO Change this if bad things happen to the ball
        |> Map.put(:y, tempBall.y + 2 * tempBall.speedY)
        game
        |> set_new_player_ball(tempBall, playerNum)
      ballHitPaddle?(game, tempBall) ->
        IO.puts "Ball hit paddle"
        tempBall = tempBall
        |> Map.put(:speedX, -1 * tempBall.speedX)
        |> Map.put(:x, tempBall.x + 2 * tempBall.speedX)
        |> set_new_player_ball(tempBall, playerNum)
      ballHitBlock?(game, tempBall) ->
        IO.puts "ball hit block"
        game
      true ->
        IO.puts "Ball is moving"
        game
        |> set_new_player_ball(tempBall, playerNum)
    end
  end

  def set_goal_score(game) do
    game
    |> Map.put(:player1score, fn game ->
      if game.ball1x > game.windowWidth do
        game.player1score + constants().goalScoreEnemyPoints
      else
        game.player1score
      end
    end)
    |> Map.put(:player1score, fn game ->
      if game.ballx < 0 do
        game.player1score + constants().goalScoreSelfPoints
      else
        game.player1score
      end
    end)
      # TODO abstract this disgusting code
      |> Map.put(:player2score, fn game ->
        if game.ball2x > game.windowWidth do
          game.player2score + constants().goalScoreSelfPoints
        else
          game.player2score
        end
      end)
      |> Map.put(:player2score, fn game ->
        if game.ball2x < 0 do
          game.player2score + constants().goalScoreEnemyPoints
        else
          game.player2score
        end
      end)
  end

  def set_new_player_ball(game, tempBall, playerNum) do
    if playerNum == 1 do
      game
      |> Map.put(:ball1x, tempBall.x)
      |> Map.put(:ball1y, tempBall.y)
      |> Map.put(:ball1SpeedX, tempBall.speedX)
      |> Map.put(:ball1SpeedY, tempBall.speedY)
    else
      game
      |> Map.put(:ball2x, tempBall.x)
      |> Map.put(:ball2y, tempBall.y)
      |> Map.put(:ball2SpeedX, tempBall.speedX)
      |> Map.put(:ball2SpeedY, tempBall.speedY)
    end
  end

  def ballHitFloorOrCeiling?(game, ball) do
    ball.y > game.windowHeight || ball.y < 0
  end

  def ballHitGoal?(game, ball) do
    ball.x > game.windowWidth || ball.x < 0
  end

  def ballHitPaddle?(game, ball) do
    (ball.x < game.player1x + constants().paddleWidth
    && ball.x > game.player1x
    && ball.y < game.player1y + constants().paddleHeight
    && ball.y > game.player1y)
    || (ball.x < game.player1x + constants().paddleWidth
    && ball.x > game.player1x
    && ball.y < game.player1y + constants().paddleHeight
    && ball.y > game.player1y)
  end

  def ballHitBlock?(game, ball) do
    ## TODO write this function when we get blocks working
    false
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

  def move_paddle(game, playerNum, move_dist) do
    if playerNum == 1 do
      game
      |> Map.put(:player1y, game.player1y + move_dist)
    else
      game
      |> Map.put(:player2y, game.player2y + move_dist)
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
