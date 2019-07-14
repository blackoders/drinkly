defmodule DrinklyTest do
  use ExUnit.Case
  doctest Drinkly

  defmodule Hello do
    def hello do
      :ok
    end
  end

  test "valid module functions test" do
    assert Drinkly.module_functions(Hello) == [:hello]
  end
end
