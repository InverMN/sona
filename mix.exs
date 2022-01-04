defmodule Sona.MixProject do
  use Mix.Project

  def project do
    [
      app: :sona,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Sona, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, github: "Kraigie/nostrum"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"}
    ]
  end
end
