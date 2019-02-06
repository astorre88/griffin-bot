defmodule GriffinBot.Scraper do
  @moduledoc """
  This module scrapes Parkrun website for collect statistics of runner bu ID.
  """

  require Logger

  @url "https://www.parkrun.ru/kuzminki/results/athletehistory/?athleteNumber="

  @spec get_statistics(binary()) :: [nil | <<_::64, _::_*8>>, ...]
  def get_statistics(id) when is_binary(id) do
    profile_url = @url <> id

    statistics =
      profile_url
      |> to_charlist
      |> request
      |> scrape_response()

    case statistics do
      "" ->
        [
          "Empty statistics!",
          nil
        ]

      result ->
        [
          "*Дата забега* | *Номер* | *Место* | *Время* | *Рейтинг* | *Личный рекорд?*\n" <>
            result <> "\n",
          profile_url
        ]
    end
  end

  @spec request(charlist()) :: {:ok, charlist()} | {:error, String.t()}
  defp request(url) do
    Application.ensure_all_started(:inets)

    Logger.log(:info, url)

    case :httpc.request(:get, {url, []}, [{:timeout, :timer.seconds(5)}], []) do
      {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ->
        {:ok, body}

      {:error, resp} ->
        case resp do
          :timeout ->
            {:error, "ERROR Response: timeout"}

          resp_tuple ->
            error_tuple = "ERROR Response: #{resp_tuple |> Tuple.to_list() |> hd}"
            Logger.log(:error, error_tuple)
            {:error, error_tuple}
        end
    end
  end

  @spec scrape_response(tuple()) :: String.t()
  defp scrape_response(response) do
    case response do
      {:ok, body} ->
        body
        |> to_string
        |> Floki.find("table#results tbody:nth-child(3)")
        |> construct_list()

      {:error, reason} ->
        reason
    end
  end

  @spec construct_list(list(tuple())) :: String.t()
  defp construct_list(element_tuples) do
    case List.last(element_tuples) do
      {"tbody", _attributes_list, rows} ->
        rows
        |> Enum.take(3)
        |> Enum.map(fn row -> read_cells(row) end)
        |> Enum.join("\n")

      _ ->
        Logger.log(:info, "Empty table!")
        "༼ つ ◕_◕ ༽つ"
    end
  end

  @spec read_cells(tuple()) :: String.t()
  defp read_cells(table_row) do
    case table_row do
      {"tr", _attributes_list, cells} ->
        cells
        |> Enum.map(fn cell -> read_cell_value(cell) end)
        |> Enum.join(" | ")

      _ ->
        Logger.log(:info, "Empty row!")
        "¯\\_(ツ)_/¯"
    end
  end

  @spec read_cell_value(tuple()) :: String.t()
  defp read_cell_value({"td", _attributes_list, [value | _]}), do: cell_value(value)
  defp read_cell_value(_), do: ""

  defp cell_value({"a", _attributes_list, link_values}), do: "`#{hd(link_values)}` "
  defp cell_value(value), do: value |> String.trim |> grummed_value

  defp grummed_value("Â"), do: "   `no`"
  defp grummed_value("ÐÐ°"), do: "   `yes`"
  defp grummed_value(value), do: "   `#{value}`"
end
