defmodule BreakoutPongWeb.GamesChannel do
  use BreakoutPongWeb, :channel

  alias BreakoutPong.Game
  alias BreakoutPong.BackupAgent

  intercept ["update_players"]

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      player = Map.get(payload, "user")
      game = game
      |> BreakoutPong.Game.add_to_lobby(player)
      |> BreakoutPong.Game.add_name(name)
      BackupAgent.put(name, game)
      update_players(name, player)

      socket = socket
        |> assign(:player, player)
        |> assign(:game, game)
        |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("start_game", _payload, socket) do
    name = socket.assigns[:name]
    game = BackupAgent.get(name) || socket.assigns[:game]

    if length(game.lobbyList) >= 2 do
      game = Game.start_game(game)
      socket = assign(socket, :game, game)
      BackupAgent.put(name, game)

      player = socket.assigns[:player]
      update_players(name, player)

      BreakoutPong.GameServer.start(name)
      BreakoutPong.GameServer.move_balls(name)
      {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
    else
      {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
    end
  end

  def handle_in("play_next_game", _map, socket) do
    name = socket.assigns[:name]

    game = Game.play_next_game(BackupAgent.get(name))
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)

    player = socket.assigns[:player]
    update_players(name, player)

    {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
  end

  def move_player_paddle(game, player, dist_change) do
    # This logic will have to change for more than 2 players
    cond do
      player == game.playerOne.name ->
        Game.move_paddle(game, 1, dist_change)
      player == game.playerTwo.name ->
        Game.move_paddle(game, 2, dist_change)
      true ->
        game
    end
  end

  def handle_in("move_paddle", %{"paddle_move_dist" => dist_change}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = BackupAgent.get(name)
    game =  move_player_paddle(game, player, dist_change)
    BackupAgent.put(name, game)

    update_players(name, player)
    {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
  end

  def handle_out("update_players", game, socket) do
    player = socket.assigns[:player]
    name = socket.assigns[:name]

    if player && name do
      push socket, "update", Game.client_view(game)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def update_players(name, player) do
    if player do
      game = BackupAgent.get(name)
      BreakoutPongWeb.Endpoint.broadcast!("games:#{name}", "update_players", game)
      {:ok, game}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
