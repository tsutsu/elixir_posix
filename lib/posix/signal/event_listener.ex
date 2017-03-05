defmodule System.POSIX.Signal.EventListener do
  use GenServer

  alias System.POSIX.Signal

  @os_overrides (case :os.type() do
    {:unix, :darwin} -> [:info]
    _                -> []
  end)

  @default_overrides [:winch, :term, :hup, :usr1, :usr2] ++ @os_overrides

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Signal.set_controller(self())

    config = Application.get_env(:posix, :signals, [])

    listen_for = Keyword.get(config, :listen, @default_overrides)
    Enum.each(listen_for, &Signal.register_signal(&1))

    {:ok, nil}
  end

  def handle_call(req, from, state), do: super(req, from, state)
  def handle_cast(req, state), do: super(req, state)

  def handle_info({:caught, code}, state) do
    sig = Signal.signal(code)
    GenEvent.notify(System.POSIX.Signal.EventManager, {:caught, sig.name, sig})
    {:noreply, state}
  end
  def handle_info(msg, state), do: super(msg, state)
end
