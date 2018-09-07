defmodule GriffinBot.Scraper do
  @moduledoc """
  This module scrapes Parkrun website for collect statistics of runner bu ID.
  """

  @url "http://www.parkrun.ru/kuzminki/results/athletehistory/?athleteNumber="

  @spec get_statistics(String.t()) :: String.t()
  def get_statistics(id) do
    @url <> id
    |> to_charlist
    |> request
    |> scrape_response
  end

  @spec request(charlist()) :: {:ok, charlist()} | {:error, String.t()}
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
        "Empty table!"
    end
  end

  @spec read_cells(tuple()) :: String.t()
  defp read_cells(table_row) do
    case table_row do
      {"tr", _attributes_list, cells} ->
        Enum.map(cells, fn cell -> read_cell_value(cell) end)
        |> Enum.join(" | ")
      _ ->
        "Empty row!"
    end
  end

  @spec read_cell_value(tuple()) :: String.t()
  defp read_cell_value(table_cell) do
    case table_cell do
      {"td", _attributes_list, values} ->
        case hd(values) do
          {"a", _attributes_list, link_values} ->
            hd(link_values)
          [link_value] ->
            link_value
          unrecognized ->
            unrecognized
        end
      _ ->
        "Empty cell!"
    end
  end
end
