defmodule GriffinBot.Scraper do
  @moduledoc """
  This module scrapes Parkrun website for collect statistics of runner bu ID.
  """

  require Logger

  @url "http://www.parkrun.ru/kuzminki/results/athletehistory/?athleteNumber="

  @spec get_statistics(binary()) :: [<<_::64, _::_*8>> | [any()], ...]
  def get_statistics(id) when is_binary(id) do
    profile_url = @url <> id

    statistics =
      profile_url
      |> to_charlist
      |> request
      |> scrape_response()

    case statistics do
      "" ->
        ["Empty statistics!", nil]

      result ->
        [result, profile_url]
    end
  end

  defp request(url) do
    Application.ensure_all_started(:inets)

    case :httpc.request(:get, {url, []}, [{:timeout, :timer.seconds(5)}], []) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        {:ok, body}

      {:error, resp} ->
        case resp do
          :timeout ->
            {:error, "ERROR Response: timeout"}

          resp_tuple ->
            {:error, "ERROR Response: #{resp_tuple |> Tuple.to_list() |> hd}"}
        end
    end
  end

  defp scrape_response({:ok, body}) do
    body
    |> to_string
    |> Floki.find("table#results tbody:nth-child(3)")
    |> List.last
    |> construct_list()
  end
  defp scrape_response({:error, reason}) do
    reason
  end

  defp construct_list({"tbody", _attributes_list, rows}) do
    rows
    |> Enum.take(3)
    |> Enum.map(fn row -> read_cells(row) end)
  end
  defp construct_list(_) do
    Logger.log(:info, "Empty table!")
    "༼ つ ◕_◕ ༽つ"
  end

  defp read_cells({"tr", _attributes_list, cells}) do
    Enum.map(cells, fn cell -> read_cell_value(cell) end)
  end
  defp read_cells(_) do
    Logger.log(:info, "Empty row!")
    "¯\\_(ツ)_/¯"
  end

  defp read_cell_value({"td", _attributes_list, [value | _]}), do: cell_value(value)
  defp read_cell_value(_), do: ""

  defp cell_value({"a", _attributes_list, link_values}), do: hd(link_values)
  defp cell_value(value), do: value |> String.trim() |> grummed_value

  defp grummed_value("Â"), do: "no"
  defp grummed_value("ÐÐ°"), do: "yes"
  defp grummed_value(value), do: value
end
