defmodule PosixErrnoTest do
  use ExUnit.Case
  doctest System.POSIX.Errno

  import System.POSIX.Errno

  test "canonicalization" do
    assert errno(:isdir).name == :eisdir
  end

  test "capitalization" do
    assert errno(:EISDIR).name == :eisdir
  end

  test "list" do
    assert length(errno_list()) > 10
  end

  test "back and forth conversion" do
    assert errno(errno(:eisdir).code).name == :eisdir
  end
end
