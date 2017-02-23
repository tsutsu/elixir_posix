# `posix_errno`

Gives your Elixir programs access to your system's `errno.h` mappings, so they can

1. understand the exit statuses of spawned programs, and

2. use `:erlang.halt/1` to tell other POSIX programs why Erlang died.

## Usage

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

`posix_errno` is implemented as a NIF written in Rust, and therefore needs Rust to be available in the build environment. Use [rustup](https://www.rustup.rs) to install.

Then, add `posix_errno` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:posix_errno, "~> 0.1.0"}]
end
```
