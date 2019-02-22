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
      paddleBuffer: 80,
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
        paddleY: 245,
        ballX: 50,
        ballY: 300,
        ballSpeedX: Enum.random(5..7),
        ballSpeedY: Enum.random([-1, 1]) * Enum.random(5..7),
      },
      playerTwo: %{
        name: "",
        score: 0,
        paddleX: 770,
        paddleY: 245,
        ballX: 750,
        ballY: 300,
        ballSpeedX: -1 * Enum.random(5..7),
        ballSpeedY: Enum.random([-1, 1]) * Enum.random(5..7),
      },
      windowHeight: 600,
      windowWidth: 800,
      winScore: 50,
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
    |> Map.put(:blocks, init_blocks())
  end

  def client_view(game) do
    %{
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
      blocks: Map.get(game, :blocks),
      winScore: game.winScore
    }
  end

  def start_game(game) do
    if length(game.lobbyList) >= 2 do
      [playerOneName | popList] = game.lobbyList
      [playerTwoName | newLobbyList] = popList
      game
      |> assign_player_value(:playerOne, :name, playerOneName)
      |> assign_player_value(:playerOne, :score, new().playerOne.score)
      |> assign_player_value(:playerTwo, :name, playerTwoName)
      |> assign_player_value(:playerTwo, :score, new().playerTwo.score)
      |> reset_positions()
      |> Map.put(:lobbyList, newLobbyList)
      |> Map.put(:isLobby, false)
    else
      game
    end
  end

  def move_balls(game) do
    if ballHitGoal?(game) do
      IO.puts "Ball scored goal."
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
      game_over?(game) ->
        game
      ballHitFloorOrCeiling?(game, playerNum) ->
        IO.puts "Ball hit floor or ceiling."
        IO.inspect(playerNum)
        game
        |> bounce_off_ceiling(playerNum)
      ballHitPaddle?(game, playerNum) ->
        IO.puts "Ball hit paddle."
        IO.inspect(playerNum)
        game
        |> bounce_off_paddle(playerNum)
      ballHitBlock?(game, playerNum) ->
        IO.puts "Ball hit block."
        IO.inspect(playerNum)
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
    paddleXPosition = get_edge_of_paddle(game, playerNum)
    reverseSpeed = -1 * tempBall.speedX
    tempBall = tempBall
    |> Map.put(:speedX, reverseSpeed)
    |> Map.put(:x, paddleXPosition + 2 * reverseSpeed)
    game
    |> set_new_player_ball(tempBall, playerNum)
  end

  def get_edge_of_paddle(game, playerNum) do
    cond do
      playerNum == 1 ->
        game.playerOne.paddleX + constants().paddleWidth
      playerNum == 2 ->
        game.playerTwo.paddleX
      true ->
        -1
    end
  end

  def bounce_off_block(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    blockListIndex = Enum.find_index(game.blocks, fn block ->
      block.hp > 0
      && block.x + constants().blockWidth >= ball.x - constants().ballRadius
      && block.x <= ball.x + constants().ballRadius
      && block.y + constants().blockHeight >= ball.y - constants().ballRadius
      && block.y <= ball.y + constants().ballRadius
    end)
    block = Enum.at(game.blocks, blockListIndex)
    bouncedBall = bounce_off_block_new_ball(ball, block)
    block = block
    |> Map.put(:hp, block.hp - 1)
    if block.hp <= 0 do
      bouncedBall = bouncedBall
      |> Map.put(:speedX, Kernel.round(bouncedBall.speedX * constants().speedChange))
      |> Map.put(:speedY, Kernel.round(bouncedBall.speedY * constants().speedChange))
      game
      |> set_block_score(playerNum)
      |> set_new_player_ball(bouncedBall, playerNum)
      |> Map.put(:blocks, List.replace_at(game.blocks, blockListIndex, block))
    else
      game
      |> set_new_player_ball(bouncedBall, playerNum)
      |> Map.put(:blocks, List.replace_at(game.blocks, blockListIndex, block))
    end
  end

  def bounce_off_block_new_ball(ball, block) do
    if bounce_off_block_top?(ball, block) do
      reverseSpeed = -1 * ball.speedY
      IO.inspect("Bounced off top/bottom of block")
      ball
      |> Map.put(:y, ball.y + 2 * reverseSpeed)
      |> Map.put(:speedY, reverseSpeed)
    else
      reverseSpeed = -1 * ball.speedX
      IO.inspect("Bounced off side of block")
      ball
      |> Map.put(:x, ball.x + 2 * reverseSpeed)
      |> Map.put(:speedX, reverseSpeed)
    end
  end

  def bounce_off_block_top?(ball, block) do
    sideBuffer = 8
    topBuffer = 10
    (block.x + constants().blockWidth - sideBuffer
      >= ball.x - constants().ballRadius
      && block.x + sideBuffer <= ball.x + constants().ballRadius)
    && (ball.y <= block.y + topBuffer
      && ball.y + constants().ballRadius >= block.y)
      || (ball.y - constants().ballRadius <= block.y + constants().blockHeight
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
    assign_player_value(game, :playerTwo, :score,
      get_score(game.playerTwo.score, constants().goalScoreEnemyPoints,
        0, game.playerTwo.ballX + constants().ballRadius))
  end

  def set_block_score(game, playerNum) do
    cond do
      playerNum == 1 ->
        game
        |> assign_player_value(:playerOne, :score,
          game.playerOne.score + constants().blockPoints)
      playerNum == 2 ->
        game
        |> assign_player_value(:playerTwo, :score,
          game.playerTwo.score + constants().blockPoints)
      true ->
        IO.puts "A ghost has scored."
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
          speedY: game.playerOne.ballSpeedY,
        }
      playerNum == 2 ->
        %{
          x: (game.playerTwo.ballX + game.playerTwo.ballSpeedX),
          y: (game.playerTwo.ballY + game.playerTwo.ballSpeedY),
          speedX: game.playerTwo.ballSpeedX,
          speedY: game.playerTwo.ballSpeedY,
        }
      true ->
        IO.puts "Error, how did you get here?"
    end
  end

  def ballHitFloorOrCeiling?(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    ball.y + constants().ballRadius >= game.windowHeight
      || ball.y - constants().ballRadius <= 0
  end

  def ballHitPaddle?(game, playerNum) do
    buffer = 5
    ball = get_new_player_ball(game, playerNum)
    (ball.x - constants().ballRadius
        <= game.playerOne.paddleX + constants().paddleWidth
      && ball.x + constants().ballRadius >= game.playerOne.paddleX - buffer
      && ball.y <= game.playerOne.paddleY + constants().paddleHeight
      && ball.y >= game.playerOne.paddleY)
    || (ball.x + constants().ballRadius
        <= game.playerTwo.paddleX + constants().paddleWidth + buffer
      && ball.x - constants().ballRadius >= game.playerTwo.paddleX
      && ball.y <= game.playerTwo.paddleY + constants().paddleHeight
      && ball.y >= game.playerTwo.paddleY)
  end

  def ballHitBlock?(game, playerNum) do
    ball = get_new_player_ball(game, playerNum)
    Enum.any?(game.blocks, fn block ->
      block.hp > 0
      && block.x + constants().blockWidth >= ball.x - constants().ballRadius
      && block.x <= ball.x + constants().ballRadius
      && block.y + constants().blockHeight >= ball.y - constants().ballRadius
      && block.y <= ball.y + constants().ballRadius
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

  # TODO Find a way to just get the damn name from the gen server child process
  # instead of using this decorator function.
  def add_name(game, name) do
    Map.put(game, :name, name)
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
      game_over?(game) ->
        game

      playerNum == 1
      && (game.playerOne.paddleY + move_dist
        < game.windowHeight - constants().paddleBuffer)
      && (game.playerOne.paddleY + move_dist >= 0) ->
        newPaddleY = game.playerOne.paddleY + move_dist
        game
        |> assign_player_value(:playerOne, :paddleY, newPaddleY)

      playerNum == 2
      && (game.playerTwo.paddleY + move_dist
        < game.windowHeight - constants().paddleBuffer)
      && (game.playerTwo.paddleY + move_dist >= 0) ->
        newPaddleY = game.playerTwo.paddleY + move_dist
        game
        |> assign_player_value(:playerTwo, :paddleY, newPaddleY)

      true ->
        IO.puts "cond fell through"
        game
    end
  end

  def game_over?(game) do
    game.isLobby
    || game.playerOne.score >= game.winScore
    || game.playerTwo.score >= game.winScore
  end

  def reset_score_and_speed(game) do
    game
    |> assign_player_value(:playerOne, :score, new().playerOne.score)
    |> assign_player_value(:playerOne, :ballSpeedX, new().playerOne.ballSpeedX)
    |> assign_player_value(:playerOne, :ballSpeedY, new().playerOne.ballSpeedY)
    |> assign_player_value(:playerTwo, :score, new().playerTwo.score)
    |> assign_player_value(:playerTwo, :ballSpeedX, new().playerTwo.ballSpeedX)
    |> assign_player_value(:playerTwo, :ballSpeedY, new().playerTwo.ballSpeedY)
  end

  def play_next_game(game) do
    if game.playerOne.score > game.playerTwo.score do
      game
      |> add_to_lobby(game.playerTwo.name)
      |> add_to_lobby(game.playerOne.name)
      |> assign_player_value(:playerOne, :score, new().playerOne.score)
      |> assign_player_value(:playerTwo, :score, new().playerTwo.score)
      |> reset_positions()
      |> Map.put(:isLobby, true)
    else
      game
      |> add_to_lobby(game.playerOne.name)
      |> add_to_lobby(game.playerTwo.name)
      |> assign_player_value(:playerOne, :score, new().playerOne.score)
      |> assign_player_value(:playerTwo, :score, new().playerTwo.score)
      |> reset_positions()
      |> Map.put(:isLobby, true)
    end
  end
end
