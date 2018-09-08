defmodule GriffinBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :griffin_bot,
      version: "0.1.0",
      elixir: "~> 1.7",
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
      {:nadia, "~> 0.4.4"},
      {:floki, "~> 0.20.0"}
    ]
  end
end
