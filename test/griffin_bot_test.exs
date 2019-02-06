defmodule GriffinBotTest do
  use ExUnit.Case
  doctest GriffinBot

  test "greets the world" do
    assert GriffinBot.hello() == :world
  end
end
