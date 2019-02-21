defmodule BreakoutPong.GameServer do
  use GenServer
  @timedelay 100

  def reg(name) do
    {:via, Registry, {BreakoutPong.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    BreakoutPong.GameSup.start_child(spec)
  end

  def start_link(name) do
    # Will have to change this later so it doesn't create a new game if the game
    # exists, but the player doesn't
    game = BreakoutPong.BackupAgent.get(name) || BreakoutPong.Game.new()
    IO.inspect(name)
    IO.inspect("genserver name above")
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def start_game(name) do
    GenServer.call(reg(name), {:start_game, name})
    :timer.send_interval(100, :tick)
  end

  def init(game) do
    {:ok, game}
  end

  def handle_cast(:start_tick, state) do
    IO.inspect("Genserver start tick function called")
  end

  def move_balls(name) do
    GenServer.call(reg(name), :move_balls)
    #:timer.send_interval(100, :tick)
    timer = Process.send_after(self(), :move_balls, 1_000)
  end

  def handle_info(:move_balls, game) do
    name = BreakoutPong.GameReg.name
    game = BreakoutPong.BackupAgent.get(name)
    game = BreakoutPong.Game.move_balls(game)
    BreakoutPongWeb.Endpoint.broadcast!("games:#{name}", "update_players", game)
    {:noreply, game}
  end
end
