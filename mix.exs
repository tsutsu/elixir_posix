defmodule PosixErrno.Mixfile do
  use Mix.Project

  @version File.read!("VERSION")

  def project do [
    app: :posix_errno,
    version: @version,
    description: description(),
    package: package(),
    elixir: "~> 1.4",
    compilers: [:rustler] ++ Mix.compilers,
    rustler_crates: rustler_crates(),
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps()
  ] end

  defp description do
    """
    Gives your Elixir programs access to the build system's `errno.h` mappings.
    """
  end

  defp package do [
    licenses: ["MIT"],
    files: ["lib", "native", "mix.exs", "VERSION", "README*"],
    maintainers: ["Levi Aul"],
    links: %{"GitHub" => "https://github.com/tsutsu/posix_errno"}
  ] end

  def application do [
    extra_applications: [:logger]
  ] end

  defp deps do [
    {:rustler, "~> 0.8.0"},
    {:exts, "~> 0.3.3"},
    {:ex_doc, ">= 0.0.0", only: :dev}
  ] end

  defp rustler_crates do [
    posix_errno: [
      path: "native/posix_errno",
      mode: (if Mix.env == :prod, do: :release, else: :debug)
    ]
  ] end
end
