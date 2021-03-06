defmodule GriffinBot.Commands do
  @moduledoc """
  This module matches bot commands.
  """

  use GriffinBot.Router
  use GriffinBot.Commander

  require Protocol

  Protocol.derive(Jason.Encoder, Model.InlineKeyboardMarkup)

  command "id" do
    Logger.log(:info, "Command /id")

    Task.start(fn -> collect_statistics(update) end)
  end

  message do
    Logger.log(:warn, "Did not match the message")

    send_message("Sorry, I couldn't understand you")
  end

  defp collect_statistics(update) do
    case parkrun_id(update) do
      nil ->
        send_message("Sorry, you didn't provide the id")

      id ->
        Logger.log(:info, id)
        [statistics_string, statistics_url] = GriffinBot.Scraper.get_statistics(id)

        send_message(statistics_string, more_button(statistics_url))
    end
  end

  defp more_button(nil), do: [parse_mode: "Markdown"]
  defp more_button(statistics_url) do
    [
      parse_mode: "Markdown",
      reply_markup: %Model.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %{
              url: statistics_url,
              text: "More..."
            }
          ]
        ]
      }
    ]
  end

  defp parkrun_id(update) do
    # update.message.from.id - User id
    case String.split(update.message.text) do
      [_command, id | _] ->
        id

      _ ->
        nil
    end
  end
end
