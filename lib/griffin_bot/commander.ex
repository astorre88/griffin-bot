defmodule GriffinBot.Commander do
  @bot_name Application.get_env(:griffin_bot, :bot_name)

  # Code injectors

  defmacro __using__(_opts) do
    quote do
      require Logger
      import GriffinBot.Commander
      alias Nadia.Model
      alias Nadia.Model.InlineQueryResult
    end
  end

  # Sender Macros

  defmacro send_message(text, options \\ []) do
    quote bind_quoted: [text: text, options: options] do
      Nadia.send_message get_chat_id(), text, options
    end
  end

  # Helpers

  defmacro get_chat_id do
    quote do
      case var!(update) do
        %{inline_query: inline_query} when not is_nil(inline_query) ->
          inline_query.from.id
        %{callback_query: callback_query} when not is_nil(callback_query) ->
          callback_query.message.chat.id
        %{message: %{chat: %{id: id}}} when not is_nil(id) ->
          id
        %{edited_message: %{chat: %{id: id}}} when not is_nil(id) ->
          id
        %{channel_post: %{chat: %{id: id}}} when not is_nil(id) ->
          id
        _ -> raise "No chat id found!"
      end
    end
  end
end
