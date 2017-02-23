defmodule System.POSIX.Signal.EventManager do
  alias System.POSIX.Signal

  @default_overrides [:info, :winch, :term, :hup, :usr1, :usr2]

  @default_handlers (case Mix.env do
    :dev -> [System.POSIX.Signal.DebugHandler]
    :prod -> [System.POSIX.Signal.GracefulShutdownHandler]
    _ -> []
  end)

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)

    Signal.set_controller(pid)

    config = Application.get_env(:posix, :signals, [])

    listen_for = Keyword.get(config, :listen, @default_overrides)
    Enum.each(listen_for, &Signal.register_signal(&1))

    handlers = Keyword.get(config, :handlers, @default_handlers)
    Enum.each(handlers, &GenEvent.add_handler(pid, &1, []))

    {:ok, pid}
  end
end
