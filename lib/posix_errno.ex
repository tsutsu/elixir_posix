defmodule System.POSIX.Errno do
  @cache_table :posix_errno
  defstruct [:code, :name, :description]

  alias System.POSIX.Errno.Impl

  def errno(name) when is_atom(name) or is_binary(name) do
    ensure_cache_populated()
    case Exts.read(@cache_table, {:by_name, canonicalize(name)}) do
      [{{_, name}, code, desc}] -> %__MODULE__{name: name, code: code, description: desc}
      [] -> nil
    end
  end

  def errno(code) when is_integer(code) do
    ensure_cache_populated()
    case Exts.read(@cache_table, {:by_code, code}) do
      [{{_, code}, name, desc}] -> %__MODULE__{name: name, code: code, description: desc}
      [] -> nil
    end
  end

  def errno_list do
    ensure_cache_populated()
    Exts.to_list(@cache_table)
    |> Enum.map(fn({name, code, desc}) ->
      %__MODULE__{name: name, code: code, description: desc}
    end)
    |> Enum.sort_by(&(&1.code))
  end

  defp ensure_cache_populated do
    table_info = ensure_cache_created()
    if table_info[:size] == 0 do
      scan()
      |> Stream.each(fn({name, code, desc}) ->
        Exts.write(@cache_table, {{:by_name, name}, code, desc})
        Exts.write(@cache_table, {{:by_code, code}, name, desc})
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
      "e" <> _ = whole -> whole
      partial          -> "e#{partial}"
    end
    String.to_atom(name)
  end

  defp scan do
    (1..65536)
    |> Stream.map(&(Impl.probe(&1)))
    |> Stream.filter(&is_tuple/1)
    |> Stream.map(fn({code, name, desc}) ->
      {canonicalize(name), code, desc}
    end)
  end
end
