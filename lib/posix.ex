defmodule System.POSIX do
  use Application

  def start(_type, _args) do
    System.POSIX.Supervisor.start_link()
  end
end
