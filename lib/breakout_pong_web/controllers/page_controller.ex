defmodule BreakoutPongWeb.PageController do
  use BreakoutPongWeb, :controller

  def game(conn, %{"gameName" => gameName}) do
    render conn, "game.html", gameName: gameName
  end

  def lobby(conn, %{"gameName" => gameName, "playerName" => playerName}) do
    render conn, "lobby.html", gameName: gameName, playerName: playerName
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
