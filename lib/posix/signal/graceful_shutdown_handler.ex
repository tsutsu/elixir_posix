defmodule System.POSIX.Signal.GracefulShutdownHandler do
  use GenEvent
  require Logger

  # handle SIGTERM -- the default signal from kill(1)
  def handle_event({:caught, :sigterm, _}, state) do
    Logger.info "Received SIGTERM; shutting down."
    :init.stop
    {:ok, state}
  end
  def handle_event(_, state), do: {:ok, state}
end
