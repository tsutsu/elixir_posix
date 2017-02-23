defmodule System.POSIX.Signal.DebugHandler do
  use GenEvent
  require Logger
  def handle_event({:caught, _, sig}, state) do
    signal_name = sig.name |> to_string |> String.upcase
    Logger.debug(["Caught signal: ", signal_name])
    {:ok, state}
  end
  def handle_event(_, state), do: {:ok, state}
end
