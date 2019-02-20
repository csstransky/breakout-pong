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
    IO.inspect(BreakoutPong.BackAgent.get(name))
    IO.inspect("genserver name above")
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def guess(name, letter) do
    GenServer.call(reg(name), {:guess, name, letter})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def start_game(name) do
    GenServer.call(reg(name), {:start_game, name})
    :timer.send_interval(100, :tick)
  end

  def handle_info(:tick, state) do
    IO.inspect("ticking")
  end


  def init(game) do
    {:ok, game}
  end

  def handle_cast(:start_tick, state) do
    IO.inspect("Genserver start tick function called")
  end

  def join_lobby(name, player) do
    game = BreakoutPong.BackupAgent.get(name) || BreakoutPong.Game.new()
    GenServer.call(reg(name), {:join_lobby, name, player})
  end

  def handle_call({:guess, name, letter}, _from, game) do
    game = BreakoutPong.Game.guess(game, letter)
    BreakoutPong.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:join_lobby, name, player}, _from, game) do
    game = BreakoutPong.Game.add_to_lobby(game, player)
    BreakoutPong.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:start_game, name}, _from, game) do
    game = BreakoutPong.Game.start_game(game)
    BreakoutPong.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end
end
