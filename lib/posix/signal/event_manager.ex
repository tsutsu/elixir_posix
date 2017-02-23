defmodule System.POSIX.Signal.EventManager do
  @default_handlers (case Mix.env do
    :dev -> [System.POSIX.Signal.DebugHandler, System.POSIX.Signal.GracefulShutdownHandler]
    :prod -> [System.POSIX.Signal.GracefulShutdownHandler]
    _ -> []
  end)

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)

    config = Application.get_env(:posix, :signals, [])

    handlers = Keyword.get(config, :handlers, @default_handlers)
    Enum.each(handlers, &GenEvent.add_handler(pid, &1, []))

    {:ok, pid}
  end
end
