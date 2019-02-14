defmodule BreakoutPongWeb.LobbyChannel do
  use BreakoutPongWeb, :channel

  alias BreakoutPong.Game
  alias BreakoutPong.BackupAgent
  alias BreakoutPong.Lobby

  def join("lobby:" <> name, payload, socket) do
    if authorized?(payload) do
      lobby = BackupAgent.get(name) || Lobby.new()
      BackupAgent.put(name, lobby)
      socket = socket
      |> assign(:lobby, lobby)
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Lobby.client_view(lobby)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  ## TODO: start game button
  def handle_in("startGame", %{"gameName" => ll}, socket) do
    name = socket.assigns[:gameName]
    game = Game.guess(socket.assigns[:game], ll)
    socket = assign(socket, :game, game)
    BackupAgent.put(name, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
