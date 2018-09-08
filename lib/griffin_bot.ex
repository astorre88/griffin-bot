defmodule GriffinBot do
  @moduledoc """
  Application supervisor module. Starts poller process.
  """

  use Application

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(GriffinBot.Poller, []),
      worker(GriffinBot.Matcher, [])
    ]

    opts = [strategy: :one_for_one, name: GriffinBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
