defmodule GriffinBot.Commands do
  use GriffinBot.Router
  use GriffinBot.Commander

  command "id" do
    Logger.log :info, "Command /id"

    Task.start(fn -> GriffinBot.Scraper.get_statistics("1530193") end)
  end
end
