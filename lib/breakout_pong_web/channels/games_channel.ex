defmodule BreakoutPongWeb.GamesChannel do
  use BreakoutPongWeb, :channel

  alias BreakoutPong.Game
  alias BreakoutPong.BackupAgent

  intercept ["update_players"]

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = BackupAgent.get(name) || Game.new()
      player = Map.get(payload, "user")
      game = BreakoutPong.Game.add_to_lobby(game, player)
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

  def handle_in("onkey", %{"keypressed" => ll}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    game = Game.key_pressed(socket.assigns[:game], ll, player)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    IO.inspect(game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  def handle_in("start_game", _payload, socket) do
    name = socket.assigns[:name]
    # TODO Should test in the fut|> Map.put(:isLobby, false)ure if retreiving the game from socket or
    # BackupAgent makes more sense here. Retreiving from socket for now.
    #game = Game.start_game(BackupAgent.get(name))
    game = Game.start_game(socket.assigns[:game])
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)

    player = socket.assigns[:player]
    update_players(name, player)
    {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
  end

  def handle_in("move_paddle", %{"paddle_move_dist" => dist_change}, socket) do
    name = socket.assigns[:name]
    player = socket.assigns[:player]
    # TODO Find out if it's faster to get from backup agent or socket, I'm
    # assuming the socket in this case since I'm already grabbing from it (I lied?)
    game = BackupAgent.get(name)
    # This logic will have to change for more than 2 players
    # TODO Find a way to correctly do this logic without having to duplicate
    # the code like this
    if player == game.player1 do
      game = Game.move_paddle(game, 1, dist_change)
      # TODO I'm not sure I actually need to use this code since we're updating
      # everything
      socket = assign(socket, :game, game)
      BackupAgent.put(name, game)

      update_players(name, player)
      {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
    else
      game = Game.move_paddle(game, 2, dist_change)
      # TODO I'm not sure I actually need to use this code since we're updating
      # everything
      socket = assign(socket, :game, game)
      BackupAgent.put(name, game)

      update_players(name, player)
      {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
    end
  end

  def handle_out("update_players", game, socket) do
    player = socket.assigns[:player]
    name = socket.assigns[:name]
    if !player && name do
      IO.puts("This player is RECEIVING update:")
      IO.puts(player)
      push socket, "update", game
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def update_players(name, player) do
    IO.puts("This player is SENDING update:")
    IO.puts(player)
    if player do
      game = BackupAgent.get(name)
      {:ok, game}
      BreakoutPongWeb.Endpoint.broadcast!("games:#{name}", "update_players", game)
    end
  end
  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  #
end
