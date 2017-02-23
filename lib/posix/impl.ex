defmodule System.POSIX.Impl do
  use Rustler, otp_app: :posix

  def errno_probe(_), do: throw :nif_not_loaded
  def signal_probe(_), do: throw :nif_not_loaded
  def signal_set_controller(_), do: throw :nif_not_loaded
  def signal_register(_), do: throw :nif_not_loaded
end
