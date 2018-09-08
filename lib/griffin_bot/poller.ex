defmodule GriffinBot.Poller do
  @moduledoc """
  Long-polling process. Consumes Telegram channel messages.
  """

  require Logger

  use GenServer

  # API

  @spec start_link() :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec update() :: :ok
  def update do
    GenServer.cast(__MODULE__, :update)
  end

  # Server

  @spec init(:ok) :: {:ok, 0}
  def init(:ok) do
    update()
    {:ok, 0}
  end

  def handle_cast(:update, offset) do
    new_offset =
      Nadia.get_updates(offset: offset)
      |> process_messages

    {:noreply, new_offset + 1, 100}
  end

  def handle_info(:timeout, offset) do
    update()
    {:noreply, offset}
  end

  def handle_info({:EXIT, _from, reason}, offset) do
    Logger.log(:info, "handle_info::exit #{inspect(reason)}")
    {:noreply, offset}
  end

  def handle_info({_ref, result}, offset) do
    Logger.log(:info, "handle_info::result #{inspect(result)}")
    {:noreply, offset}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, offset) do
    Logger.log(:info, "handle_info::down #{inspect(reason)}")
    {:noreply, offset}
  end

  defp process_messages({:ok, []}), do: -1

  defp process_messages({:ok, results}) do
    results
    |> Enum.map(fn %{update_id: id} = message ->
      message
      |> process_message

      id
    end)
    |> List.last()
  end

  defp process_messages({:error, %Nadia.Model.Error{reason: reason}}) do
    Logger.log(:error, reason)

    -1
  end

  defp process_messages({:error, error}) do
    Logger.log(:error, error)

    -1
  end

  defp process_message(nil), do: Logger.log(:info, "nil")

  defp process_message(message) do
    try do
      GriffinBot.Matcher.match(message)
    rescue
      err in MatchError ->
        Logger.log(:warn, "Errored with #{err} at #{Poison.encode!(message)}")
    end
  end
end
