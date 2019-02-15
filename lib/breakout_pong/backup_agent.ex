defmodule BreakoutPong.BackupAgent do
  use Agent

  # This is basically just a global mutable map.
  # TODO: Add timestamps and expiration.

  def start_link(_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(name, player, game) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, player, game)
    end
  end

  def get(name, player) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name, player)
    end
  end
end
