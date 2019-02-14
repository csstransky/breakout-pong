defmodule BreakoutPongWeb.PageController do
  use BreakoutPongWeb, :controller

  def game(conn, %{"name" => name}) do
    render conn, "game.html", name: name
  end

  def lobby(conn, %{"gameName" => gameName, "playerName" => playerName}) do
    render conn, "lobby.html", gameName: gameName, playerName: playerName
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
