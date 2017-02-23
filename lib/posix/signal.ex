defmodule System.POSIX.Signal do
  @cache_table :posix_signals
  defstruct [:code, :name]

  alias System.POSIX.Impl

  def signal(name) when is_atom(name) or is_binary(name) do
    ensure_cache_populated()
    case Exts.read(@cache_table, {:by_name, canonicalize(name)}) do
      [{{_, name}, code}] -> %__MODULE__{name: name, code: code}
      [] -> nil
    end
  end

  def signal(code) when is_integer(code) do
    ensure_cache_populated()
    case Exts.read(@cache_table, {:by_code, code}) do
      [{{_, code}, name}] -> %__MODULE__{name: name, code: code}
      [] -> nil
    end
  end

  def signal_list do
    ensure_cache_populated()
    Exts.match(@cache_table, {{:by_name, :"$1"}, :"$2"}).values
    |> Enum.map(fn([name, code]) ->
      %__MODULE__{name: name, code: code}
    end)
    |> Enum.sort_by(&(&1.code))
  end

  def set_controller(pid) do
    Impl.signal_set_controller(pid)
  end

  def register_signal(name) do
    case signal(name) do
      nil -> raise ArgumentError, "no signal named '#{name}'"
      sig -> Impl.signal_register(sig.code)
    end
  end

  defp ensure_cache_populated do
    table_info = ensure_cache_created()
    if table_info[:size] == 0 do
      scan()
      |> Stream.each(fn({name, code}) ->
        Exts.write(@cache_table, {{:by_name, name}, code})
        Exts.write(@cache_table, {{:by_code, code}, name})
      end)
      |> Stream.run
    end
  end

  defp ensure_cache_created do
    case Exts.info(@cache_table) do
      nil  -> Exts.info(Exts.new(@cache_table, concurrency: :read))
      info -> info
    end
  end

  defp canonicalize(name) when is_atom(name), do: canonicalize(to_string(name))
  defp canonicalize(name) when is_binary(name) do
    name = case String.downcase(name) do
      "sig" <> _ = whole -> whole
      partial          -> "sig#{partial}"
    end
    String.to_atom(name)
  end

  defp scan do
    (1..65536)
    |> Stream.map(&(Impl.signal_probe(&1)))
    |> Stream.filter(&is_tuple/1)
    |> Stream.map(fn({code, name}) ->
      {canonicalize(name), code}
    end)
  end
end
