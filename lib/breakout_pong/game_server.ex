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
    GenServer.call(reg(name), {:move_balls, name})
  end

  def handle_call({:move_balls, name}, _from, game) do
    game = BreakoutPong.BackupAgent.get(name)
    game = BreakoutPong.Game.move_balls(game)
    BreakoutPong.BackupAgent.put(name, game)
    BreakoutPongWeb.Endpoint.broadcast!("games:#{name}", "update_players", game)
    timer = Process.send_after(self(), :move_balls, 50)
    {:reply, name, game}
  end

  def handle_info(:move_balls, game) do
    # IO.puts "LOOK EHRER"
    # IO.inspect(Registry.lookup(__MODULE__, key))
    # name = GenServer.whereis(self())
    game = BreakoutPong.BackupAgent.get(game.name)
    game = BreakoutPong.Game.move_balls(game)
    BreakoutPong.BackupAgent.put(game.name, game)
    BreakoutPongWeb.Endpoint.broadcast!("games:#{game.name}", "update_players", game)
    timer = Process.send_after(self(), :move_balls, 50)
    {:noreply, game}
  end
end
