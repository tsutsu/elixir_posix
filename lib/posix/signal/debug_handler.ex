defmodule System.POSIX.Signal.DebugHandler do
  use GenEvent
  require Logger
  import System.POSIX.Signal, only: [signal: 1]

  def handle_event({:caught, code}, state) do
    signal_name = signal(code).name |> to_string |> String.upcase
    Logger.debug(["Caught signal: ", signal_name])
    {:ok, state}
  end
  def handle_event(_, state), do: {:ok, state}
end
