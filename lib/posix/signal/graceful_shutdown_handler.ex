defmodule System.POSIX.Signal.GracefulShutdownHandler do
  use GenEvent

  # handle SIGTERM -- the default signal from kill(1)
  def handle_event({:caught, :term}, state) do
    :init.stop
    {:ok, state}
  end
  def handle_event(_, state), do: {:ok, state}
end
