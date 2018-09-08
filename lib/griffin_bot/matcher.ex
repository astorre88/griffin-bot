defmodule GriffinBot.Matcher do
  use GenServer
  alias GriffinBot.Commands

  # Server

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, 0}
  def init(:ok) do
    {:ok, 0}
  end

  def handle_cast(message, state) do
    Commands.match_message(message)

    {:noreply, state}
  end

  # Client

  @spec match(any()) :: :ok
  def match(message) do
    GenServer.cast(__MODULE__, message)
  end
end
