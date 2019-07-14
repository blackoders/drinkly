defmodule Drinkly do
  def module_functions(module_name) do
    apply(module_name, :__info__, [:functions])
    |> Keyword.keys()
  end
end
