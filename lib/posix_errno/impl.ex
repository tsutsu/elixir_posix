defmodule System.POSIX.Errno.Impl do
  use Rustler, otp_app: :posix_errno
  def probe(_), do: throw :nif_not_loaded
end
