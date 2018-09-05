defmodule GriffinBot.Commands do
  use GriffinBot.Router
  use GriffinBot.Commander

  command "id" do
    Logger.log :info, "Command /id"

    send_message "parkrun"
  end
end
