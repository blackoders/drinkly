defmodule DrinklyTest do
  use ExUnit.Case
  doctest Drinkly

  test "greets the world" do
    assert Drinkly.hello() == :world
  end
end
