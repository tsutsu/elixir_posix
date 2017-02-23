# `System.POSIX`

The `posix` Hex package gives the Erlang Runtime System access to POSIX features of the build environment.

The API of the `posix` library is portable, using Erlang atoms rather than OS-dependent magic constants. However, a release built using `posix` is _not_ portable: a NIF is generated which "burns in" the properties of the build environment.

The `posix` package is thus best suited for use in SaaS server software that does not require redistribution.

## Feature: `sigaction(2)` control

`System.POSIX.SignalListener` allows your Elixir release to modify the behavior of ERTS in response to POSIX signals. You can use this to:

* refresh configuration on `SIGHUP`, like a regular daemon;

* shut down gracefully on `SIGINT`;

* allow users to poll for progress information using `SIGINFO` (Ctrl+T), like `dd(1)`

### Usage

In your `config.exs`, specify one or more signal-handling modules:

```elixir
config :posix, :signals,
  handlers: [HandlerFoo, HandlerBar]
```

`System.POSIX.SignalListener` is implemented as a `GenEvent` server; the modules you register should look like `GenEvent` handlers, and should just react to the signals they care about:

```elixir
defmodule System.GracefulShutdownHandler do
  use GenEvent

  # handle SIGTERM -- the default signal from kill(1)
  def handle_event({:caught, :term}, state) do
    :init.stop
    {:ok, state}
  end
  def handle_event(_, state), do: {:ok, state}
end
```

By default, the set of signals `System.POSIX.Signal` registers for is `[:info, :winch, :term, :hup, :usr1, :usr2]`. You can define your own set:

```elixir
config :posix, :signals,
  listen: [:pipe, :alrm, :urg, :abrt]
```

Don't be surprised, though, if overriding signals ERTS expected to catch itself causes strange behavior. The default set is safe; other signals may not be.

## Feature: `errno.h` mappings

`System.POSIX.Errno` gives your Elixir programs (portable!) access to the constants from `errno.h`, and to the `strerror(3)` function. This enables you to:

1. understand the exit statuses of spawned programs, and

2. use `:erlang.halt/1` to tell other POSIX programs why Erlang died.

### Usage

Interpreting exit codes:

```elixir
import System.POSIX.Errno

too_many_args = "1234567890" |> List.duplicate(100_000)

{_, exit_code} = System.cmd("true", too_many_args)

IO.puts ["Process failed: ", errno(exit_code).description]
# => Process failed: Argument list too long
```

Emitting exit codes:

```elixir
# something terrible has happened to a process we're doing IPC with!
errno(:EPIPE).code |> :erlang.halt
```

## Installation

`System.POSIX` is implemented as a NIF written in Rust. To compile this package, you therefore need Rust to be available in your build environment. Use [rustup](https://www.rustup.rs) to install.

Presuming a Rust installation, just add `posix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:posix, "~> 0.1.0"}]
end
```
