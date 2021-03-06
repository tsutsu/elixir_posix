defmodule System.POSIX.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(System.POSIX.Signal.EventListener, []),
      worker(System.POSIX.Signal.EventManager, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
