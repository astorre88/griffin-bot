defmodule GriffinBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :griffin_bot,
      version: "0.1.3",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {GriffinBot, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Core
      {:jason, "~> 1.1"},
      {:nadia, "~> 0.5.0"},
      {:floki, "~> 0.21.0"},

      # DevOps
      {:distillery, "~> 2.0"}
    ]
  end
end
