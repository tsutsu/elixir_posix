defmodule System.POSIX.Mixfile do
  use Mix.Project

  @version File.read!("VERSION")

  def project do [
    app: :posix,
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
    Gives the Erlang Runtime System access to POSIX features of the build environment (currently, errno and sigaction.)
    """
  end

  defp package do [
    licenses: ["MIT"],
    files: ["lib", "native", "mix.exs", "VERSION", "README*"],
    maintainers: ["Levi Aul"],
    links: %{"GitHub" => "https://github.com/tsutsu/elixir_posix"}
  ] end

  def application do [
    mod: {System.POSIX, []},
    extra_applications: [:logger]
  ] end

  defp deps do [
    {:rustler, "~> 0.8.0"},
    {:exts, "~> 0.3.3"},
    {:ex_doc, ">= 0.0.0", only: :dev}
  ] end

  defp rustler_crates do [
    posix: [
      path: "native/posix",
      mode: (if Mix.env == :prod, do: :release, else: :debug)
    ]
  ] end
end
