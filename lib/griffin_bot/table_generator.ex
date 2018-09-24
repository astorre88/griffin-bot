defmodule GriffinBot.TableGenerator do
  @moduledoc """
  This module generate image from html.
  """

  require EEx

  @filename "templates/table.html.eex"

  @spec generate_image(any()) :: none()
  def generate_image(statistics) do
    statistics
    |> generate_html
    |> convert
  end

  @spec generate_html(any()) :: any()
  def generate_html(statistics) do
    EEx.eval_file(@filename, statistics: statistics)
  end

  defp convert(html) do
    executable = "/usr/local/bin/wkhtmltoimage"
    template_name = template_file(html)

    arguments = [
      "--format",
      :jpg,
      template_name,
      "-"
    ]

    result =
      Porcelain.exec(
        executable,
        arguments,
        in: html,
        out: :string,
        err: :string
      )

    case result.status do
      0 ->
        {:ok, result.out}
      _ ->
        {:error, result.error}
    end
  end

  defp template_file(data) do
    template = Path.join(System.tmp_dir(), random_filename()) <> ".html"
    {:ok, file} = File.open(template, [:write])
    IO.binwrite(file, data)
    File.close(file)
    template
  end

  defp random_filename(length \\ 16) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
