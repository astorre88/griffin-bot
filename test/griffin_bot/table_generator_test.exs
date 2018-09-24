defmodule GriffinBot.TableGeneratorTest do
  use ExUnit.Case, async: false

  test "generate the html table" do
    assert GriffinBot.TableGenerator.generate_html([~w(a b c), ~w(d e f), ~w(g h i)]) =~
      "<td class=\"tg-0pky\">a</td>\n        \n          <td class=\"tg-0pky\">b</td>\n        \n          <td class=\"tg-0pky\">c</td>"
  end

  test "generate the image table" do
    assert GriffinBot.TableGenerator.generate_image([~w(a b c), ~w(d e f), ~w(g h i)]) ==
      {:ok, []}
  end
end
