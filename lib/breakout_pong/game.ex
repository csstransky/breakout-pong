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
      name: "",
      isLobby: true,
      lobbyList: [],
      playerOne: %{
        name: "",
        score: 0,
        paddleX: 10,
        paddleY: 0,
        ballX: 100,
        ballY: 100,
        ballSpeedX: 20,
        ballSpeedY: 20,
      },
      playerTwo: %{
        name: "",
        score: 0,
        paddleX: 770,
        paddleY: 0,
        ballX: 570,
        ballY: 200,
        ballSpeedX: 20,
        ballSpeedY: 20,
      },
      windowHeight: 600,
      windowWidth: 800,
    }
  end

  def assign_player_value(game, player, type, value) do
    playerMap = Map.get(game, player)
    Map.put(game, player, Map.put(playerMap, type, value))
  end

  def reset_positions(game) do
    game
    |> assign_player_value(:playerOne, :ballX, new().playerOne.ballX)
    |> assign_player_value(:playerOne, :ballY, new().playerOne.ballY)
    |> assign_player_value(:playerOne, :ballSpeedX, new().playerOne.ballSpeedX)
    |> assign_player_value(:playerOne, :ballSpeedY, new().playerOne.ballSpeedY)
    |> assign_player_value(:playerOne, :paddleX, new().playerOne.paddleX)
    |> assign_player_value(:playerOne, :paddleY, new().playerOne.paddleY)
    |> assign_player_value(:playerTwo, :ballX, new().playerTwo.ballX)
    |> assign_player_value(:playerTwo, :ballY, new().playerTwo.ballY)
    |> assign_player_value(:playerTwo, :ballSpeedX, new().playerTwo.ballSpeedX)
    |> assign_player_value(:playerTwo, :ballSpeedY, new().playerTwo.ballSpeedY)
    |> assign_player_value(:playerTwo, :paddleX, new().playerTwo.paddleX)
    |> assign_player_value(:playerTwo, :paddleY, new().playerTwo.paddleY)
  end

  def client_view(game) do
    x = %{
      #TODO, this is a giant mess that will have to be fixed
      isLobby: game.isLobby,
      lobbyList: game.lobbyList,
      player1: game.playerOne.name,
      player2: game.playerTwo.name,
      ball1x: game.playerOne.ballX,
      ball1y: game.playerOne.ballY,
      ball2x: game.playerTwo.ballX,
      ball2y: game.playerTwo.ballY,
      player1x: game.playerOne.paddleX,
      player1y: game.playerOne.paddleY,
      player2x: game.playerTwo.paddleX,
      player2y: game.playerTwo.paddleY,
      player1score: game.playerOne.score,
      player2score: game.playerTwo.score,
      windowWidth: Map.get(game, :windowWidth),
      windowHeight: Map.get(game, :windowHeight),
    }
    x
  end

  def start_game(game) do
    if length(game.lobbyList) >= 2 do
      [playerOneName | popList] = game.lobbyList
      [playerTwoName | newLobbyList] = popList
      game
      |> assign_player_value(:playerOne, :name, playerOneName)
      |> assign_player_value(:playerTwo, :name, playerTwoName)
      |> Map.put(:lobbyList, newLobbyList)
      |> Map.put(:isLobby, false)
    else
      # TODO This is strictly for debugging and will have to be removed at some
      # point before deployment, hence the awkward else if statement
      if length(game.lobbyList) == 1 do
        [playerOneName | newLobbyList] = game.lobbyList
        game
        |> assign_player_value(:playerOne, :name, playerOneName)
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
    game.playerOne.ballX > game.windowWidth
    || game.playerOne.ballX < 0
    || game.playerTwo.ballX > game.windowWidth
    || game.playerTwo.ballX < 0
  end

  def move_player_ball(game, playerNum) do
    tempBall = fn (game, playerNum) ->
      cond do
        playerNum == 1 ->
          %{
            x: game.playerOne.ballX + game.playerOne.ballSpeedX,
            y: game.playerOne.ballY + game.playerOne.ballSpeedY,
            speedX: game.playerOne.speedX,
            speedY: game.playerOne.speedY,
          }
        playerNum == 2 ->
          %{
            x: game.playerTwo.ballX + game.playerTwo.ballSpeedX,
            y: game.playerTwo.ballY + game.playerTwo.ballSpeedY,
            speedX: game.playerTwo.speedX,
            speedY: game.playerTwo.speedY,
          }
        true ->
          "Error, how did you get here?"
      end
    end

    cond do
      ballHitFloorOrCeiling?(game, playerNum) ->
        IO.puts "Ball hit ceiling."
        game
        |> bounce_off_ceiling(playerNum)
      ballHitPaddle?(game, playerNum) ->
        IO.puts "Ball hit paddle."
        game
        |> bounce_off_paddle(playerNum)
      ballHitBlock?(game, playerNum) ->
        IO.puts "Ball hit block."
        game
      true ->
        IO.puts "Ball is moving"
        game = no_bounce_move(game, playerNum)
        IO.inspect(game)
        game
    end
  end

  def no_bounce_move(game, playerNum) do
    tempBall = get_player_ball(game, playerNum)
    tempBall = tempBall
    |> Map.put(:x, tempBall.x + tempBall.speedX)
    |> Map.put(:y, tempBall.y + tempBall.speedY)
    IO.inspect(tempBall)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def bounce_off_ceiling(game, playerNum) do
    tempBall = get_player_ball(game, playerNum)
    tempBall = tempBall
    |> Map.put(:speedY, -1 * tempBall.speedY)
    # TODO Change this if bad things happen to the ball
    |> Map.put(:y, tempBall.y + 2 * tempBall.speedY)
    |> Map.put(:x, tempBall.x + tempBall.speedX)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def bounce_off_paddle(game, playerNum) do
    tempBall = get_player_ball(game, playerNum)
    tempBall = tempBall
    |> Map.put(:speedX, -1 * tempBall.speedX)
    |> Map.put(:x, tempBall.x + 2 * tempBall.speedX)
    |> Map.put(:y, tempBall.y + tempBall.speedY)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def get_score(score, pointsScored, boundary1, boundary2) do
    if boundary1 > boundary2 do
      score + pointsScored
    else
      score
    end
  end

  def set_goal_score(game) do
    game
    |> assign_player_value(:playerOne, :score,
         get_score(game.playerOne.score, constants().goalScoreEnemyPoints,
           game.playerOne.ballX, game.windowWidth))
    |> assign_player_value(:playerOne, :score,
         get_score(game.playerOne.score, constants().goalScoreSelfPoints,
           0, game.playerOne.ballX))
    |> assign_player_value(:playerTwo, :score,
         get_score(game.playerTwo.score, constants.goalScoreSelfPoints,
           game.playerTwo.ballX, game.windowWidth))
    |> assign_player_value(:playerTwo, :score,
         get_score(game.playerTwo.score, constants.goalScoreEnemyPoints,
           0, game.playerTwo.ballX))
  end

  def set_new_player_ball(game, tempBall, playerNum) do
    cond do
      playerNum == 1 ->
        game
        |> assign_player_value(:playerOne, :ballX, tempBall.x)
        |> assign_player_value(:playerOne, :ballY, tempBall.y)
        |> assign_player_value(:playerOne, :ballSpeedX, tempBall.speedX)
        |> assign_player_value(:playerOne, :ballSpeedY, tempBall.speedY)
      playerNum == 2 ->
        game
        |> assign_player_value(:playerTwo, :ballX, tempBall.x)
        |> assign_player_value(:playerTwo, :ballY, tempBall.y)
        |> assign_player_value(:playerTwo, :ballSpeedX, tempBall.speedX)
        |> assign_player_value(:playerTwo, :ballSpeedY, tempBall.speedY)
      true ->
        game
    end
  end

  def get_player_ball(game, playerNum) do
    cond do
      playerNum == 1 ->
        %{
          x: game.playerOne.ballX + game.playerOne.ballSpeedX,
          y: game.playerOne.ballY + game.playerOne.ballSpeedY,
          speedX: game.playerOne.ballSpeedX,
          speedY: game.playerOne.ballSpeedX,
        }
      playerNum == 2 ->
        IO.puts("WHY AREN'T YOU WORKING?")
        %{
          x: game.playerTwo.ballX + game.playerTwo.ballSpeedX,
          y: game.playerTwo.ballY + game.playerTwo.ballSpeedY,
          speedX: game.playerTwo.ballSpeedX,
          speedY: game.playerTwo.ballSpeedY,
        }
      true ->
        "Error, how did you get here?"
    end
  end

  def ballHitFloorOrCeiling?(game, playerNum) do
    ball = get_player_ball(game, playerNum)
    ball.y > game.windowHeight || ball.y < 0
  end

  def ballHitPaddle?(game, playerNum) do
    ball = get_player_ball(game, playerNum)

    (ball.x < game.playerOne.paddleX + constants().paddleWidth
      && ball.x > game.playerOne.paddleX
      && ball.y < game.playerOne.paddleY + constants().paddleHeight
      && ball.y > game.playerOne.paddleY)
    || (ball.x < game.playerTwo.paddleX + constants().paddleWidth
      && ball.x > game.playerTwo.paddleX
      && ball.y < game.playerTwo.paddleY + constants().paddleHeight
      && ball.y > game.playerTwo.paddleY)
  end

  def ballHitBlock?(game, playerNum) do
    ball = get_player_ball(game, playerNum)
    ## TODO write this function when we get blocks working
    false
  end

  # TODO Find a way to just get the damn name from the gen server
  def add_name(game, name) do
    game = Map.put(game, :name, name)
  end

  def add_to_lobby(game, playerName) do
    if Enum.member?(game.lobbyList, playerName) do
      game
    else
      game
      |> Map.put(:lobbyList, game.lobbyList ++ [playerName])
    end
  end

  def remove_from_lobby(game, playerName) do
    if Enum.member?(game.lobbyList, playerName) do
      game
      |> Map.put(:lobbyList, game.lobbyList ++ [playerName])
    else
      game
    end
  end

  def move_paddle(game, playerNum, move_dist) do
    cond do
      playerNum == 1
        ## TODO Get rid of these magic numbers 60 (80 actually)
      && (game.playerOne.paddleY + move_dist < game.windowHeight - 80)
      && (game.playerOne.paddleY + move_dist >= 0) ->
        newPaddleY = game.playerOne.paddleY + move_dist
        game
        |> assign_player_value(:playerOne, :paddleY, newPaddleY)
      playerNum == 2
        ## TODO Get rid of these magic numbers 60 (80 actually)
      && (game.playerTwo.paddleY + move_dist < game.windowHeight - 80)
      && (game.playerTwo.paddleY + move_dist >= 0) ->
        newPaddleY = game.playerTwo.paddleY + move_dist
        game
        |> assign_player_value(:playerTwo, :paddleY, newPaddleY)
      true ->
        IO.inspect("cond fell through")
        game
    end
  end
end
