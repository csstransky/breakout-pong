defmodule BreakoutPong.Game do
  def constants do
    %{
      paddleWidth: 20,
      paddleHeight: 110,
      ballRadius: 8,
      goalScoreEnemyPoints: 10,
      goalScoreSelfPoints: 5,
      blockPoints: 1,
      winScore: 100,
      speedChange: 1.14,
      blockWidth: 40,
      blockHeight: 100,
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
        paddleY: 5,
        ballX: 100,
        ballY: 100,
        ballSpeedX: 4,
        ballSpeedY: 4,
      },
      playerTwo: %{
        name: "",
        score: 0,
        paddleX: 770,
        paddleY: 5,
        ballX: 570,
        ballY: 200,
        ballSpeedX: -4,
        ballSpeedY: -4,
      },
      windowHeight: 600,
      windowWidth: 800,
      blocks: init_blocks(),
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
    game.playerOne.ballX - constants().ballRadius > game.windowWidth
    || game.playerOne.ballX + constants().ballRadius < 0
    || game.playerTwo.ballX - constants().ballRadius > game.windowWidth
    || game.playerTwo.ballX + constants().ballRadius < 0
  end

  def move_player_ball(game, playerNum) do
    cond do
      ballHitFloorOrCeiling?(game, playerNum) ->
        IO.puts "Ball hit floor or ceiling."
        game
        |> bounce_off_ceiling(playerNum)
      ballHitPaddle?(game, playerNum) ->
        IO.puts "Ball hit paddle."
        game
        |> bounce_off_paddle(playerNum)
      ballHitBlock?(game, playerNum) ->
        IO.puts "Ball hit block."
        game
        |> bounce_off_block(playerNum)
      true ->
        game
        |> no_bounce_move(playerNum)
    end
  end

  def no_bounce_move(game, playerNum) do
    tempBall = get_new_player_ball(game, playerNum)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def bounce_off_ceiling(game, playerNum) do
    tempBall = get_new_player_ball(game, playerNum)
    reverseSpeed = -1 * tempBall.speedY
    tempBall = tempBall
    |> Map.put(:speedY, reverseSpeed)
    |> Map.put(:y, tempBall.y + 2 * reverseSpeed)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def bounce_off_paddle(game, playerNum) do
    tempBall = get_new_player_ball(game, playerNum)
    reverseSpeed = -1 * tempBall.speedX
    tempBall = tempBall
    |> Map.put(:speedX, reverseSpeed)
    |> Map.put(:x, tempBall.x + 2 * reverseSpeed)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def bounce_off_block(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    blockListIndex = Enum.find_index(game.blocks, fn block ->
      block.hp > 0
      && block.x + constants().blockWidth > ball.x + constants().ballRadius
      && block.x < ball.x - constants().ballRadius
      && block.y + constants().blockHeight > ball.y + constants().ballRadius
      && block.y < ball.y - constants().ballRadius
    end)
    block = Enum.at(game.blocks, blockListIndex)
    bouncedBall = bounce_off_block_new_ball(ball, block)
    block = block
    |> Map.put(:hp, block.hp - 1)
      IO.inspect("LOOK HERE CIRSTINASFDKN")
      IO.inspect(ball)
      IO.inspect(playerNum)
    IO.inspect(block)
    IO.inspect(bouncedBall)
    if block.hp <= 0 do
      # TODO Use better math to get this working in a linear fashion
      bouncedBall = bouncedBall
      |> Map.put(:speedX, Kernel.round(bouncedBall.speedX * constants().speedChange))
      |> Map.put(:speedY, Kernel.round(bouncedBall.speedY * constants().speedChange))
      IO.inspect(bouncedBall)
      game = game
      |> set_block_score(playerNum)
      |> set_new_player_ball(bouncedBall, playerNum)
      |> Map.put(:blocks, List.insert_at(game.blocks, blockListIndex, block))
      IO.inspect(game)
      game
    else
      game
      |> set_new_player_ball(bouncedBall, playerNum)
      |> Map.put(:blocks, List.insert_at(game.blocks, blockListIndex, block))
    end
  end

  def bounce_off_block_new_ball(ball, block) do
    if bounce_off_block_top?(ball, block) do
      reverseSpeed = -1 * ball.speedY
      IO.inspect("I HIT THE TOP OF THE BLOCK")
      ball
      |> Map.put(:y, ball.y + 2 * reverseSpeed)
      |> Map.put(:speedY, reverseSpeed)
    else
      reverseSpeed = -1 * ball.speedX
      IO.inspect("I HIT THE SIDE OF THE BLOCK")
      ball
      |> Map.put(:x, ball.x + 2 * reverseSpeed)
      |> Map.put(:speedX, reverseSpeed)
    end
  end

  def bounce_off_block_top?(ball, block) do
    # TODO Mess with these buffers until it looks right
    sideBuffer = 4
    topBuffer = 10
    (ball.x <= block.x + constants().blockWidth - sideBuffer
      && ball.x >= block.x + sideBuffer)
    && (ball.y <= block.y + topBuffer
        && ball.y + constants().ballRadius >= block.y)
      || (ball.y - constants.ballRadius <= block.y + constants().blockHeight
        && ball.y >= block.y + constants().blockHeight - topBuffer)
  end

  def increase_all_balls_speed(game) do
    game
    |> assign_player_value(:playerOne, :ballSpeedX,
      game.playerOne.ballSpeedX + constants().speedChange)
    |> assign_player_value(:playerOne, :ballSpeedY,
      game.playerOne.ballSpeedY + constants().speedChange)
    |> assign_player_value(:playerTwo, :ballSpeedX,
      game.playerTwo.ballSpeedX + constants().speedChange)
    |> assign_player_value(:playerTwo, :ballSpeedY,
      game.playerTwo.ballSpeedY + constants().speedChange)
  end

  def get_score(score, pointsScored, boundary1, boundary2) do
    if boundary1 > boundary2 do
      score + pointsScored
    else
      score
    end
  end

  def set_goal_score(game) do
    game = assign_player_value(game, :playerOne, :score,
      get_score(game.playerOne.score, constants().goalScoreEnemyPoints,
        game.playerOne.ballX - constants().ballRadius, game.windowWidth))
    game = assign_player_value(game, :playerTwo, :score,
      get_score(game.playerTwo.score, constants().goalScoreSelfPoints,
        0, game.playerOne.ballX + constants().ballRadius))
    game = assign_player_value(game, :playerOne, :score,
      get_score(game.playerOne.score, constants().goalScoreSelfPoints,
        game.playerTwo.ballX - constants().ballRadius, game.windowWidth))
    game = assign_player_value(game, :playerTwo, :score,
      get_score(game.playerTwo.score, constants().goalScoreEnemyPoints,
        0, game.playerTwo.ballX + constants().ballRadius))
  end

  def set_block_score(game, playerNum) do
    cond do
      playerNum == 1 ->
        game
        |> assign_player_value(:playerOne, :score, game.playerOne.score + constants().blockPoints)
      playerNum == 2 ->
        game
        |> assign_player_value(:playerTwo, :score, game.playerOne.score + constants().blockPoints)
      true ->
        IO.inspect("A ghost has scored.")
    end
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

  def get_new_player_ball(game, playerNum) do
    cond do
      playerNum == 1 ->
        %{
          x: (game.playerOne.ballX + game.playerOne.ballSpeedX),
          y: (game.playerOne.ballY + game.playerOne.ballSpeedY),
          speedX: game.playerOne.ballSpeedX,
          speedY: game.playerOne.ballSpeedX,
        }
      playerNum == 2 ->
        %{
          x: (game.playerTwo.ballX + game.playerTwo.ballSpeedX),
          y: (game.playerTwo.ballY + game.playerTwo.ballSpeedY),
          speedX: game.playerTwo.ballSpeedX,
          speedY: game.playerTwo.ballSpeedY,
        }
      true ->
        IO.put "Error, how did you get here?"
    end
  end

  def ballHitFloorOrCeiling?(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    ball.y + constants().ballRadius >= game.windowHeight
      || ball.y - constants().ballRadius <= 0
  end

  def ballHitPaddle?(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    buffer = 10
    (ball.x - constants().ballRadius <= game.playerOne.paddleX + constants().paddleWidth
      && ball.x + constants().ballRadius >= game.playerOne.paddleX - buffer
      && ball.y <= game.playerOne.paddleY + constants().paddleHeight
      && ball.y >= game.playerOne.paddleY)
    || (ball.x + constants().ballRadius <= game.playerTwo.paddleX + constants().paddleWidth
      && ball.x - constants().ballRadius >= game.playerTwo.paddleX - buffer
      && ball.y <= game.playerTwo.paddleY + constants().paddleHeight
      && ball.y >= game.playerTwo.paddleY)
  end

  def ballHitBlock?(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    Enum.any?(game.blocks, fn block ->
      block.hp > 0
      && block.x + constants().blockWidth > ball.x + constants().ballRadius
      && block.x < ball.x - constants().ballRadius
      && block.y + constants().blockHeight > ball.y + constants().ballRadius
      && block.y < ball.y - constants().ballRadius
    end)
  end

  def init_blocks() do
    [ %{x: 310, y: 1, hp: 1},
      %{x: 350, y: 1, hp: 2},
      %{x: 390, y: 1, hp: 4},
      %{x: 430, y: 1, hp: 2},
      %{x: 470, y: 1, hp: 1},
      %{x: 310, y: 100, hp: 1},
      %{x: 350, y: 100, hp: 2},
      %{x: 390, y: 100, hp: 4},
      %{x: 430, y: 100, hp: 2},
      %{x: 470, y: 100, hp: 1},
      %{x: 310, y: 200, hp: 1},
      %{x: 350, y: 200, hp: 2},
      %{x: 390, y: 200, hp: 4},
      %{x: 430, y: 200, hp: 2},
      %{x: 470, y: 200, hp: 1},
      %{x: 310, y: 300, hp: 1},
      %{x: 350, y: 300, hp: 2},
      %{x: 390, y: 300, hp: 4},
      %{x: 430, y: 300, hp: 2},
      %{x: 470, y: 300, hp: 1},
      %{x: 310, y: 400, hp: 1},
      %{x: 350, y: 400, hp: 2},
      %{x: 390, y: 400, hp: 4},
      %{x: 430, y: 400, hp: 2},
      %{x: 470, y: 400, hp: 1},
      %{x: 310, y: 499, hp: 1},
      %{x: 350, y: 499, hp: 2},
      %{x: 390, y: 499, hp: 4},
      %{x: 430, y: 499, hp: 2},
      %{x: 470, y: 499, hp: 1}]
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
