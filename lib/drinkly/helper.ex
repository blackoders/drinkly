defmodule Drinkly.Helper do
  def emoji(text) do
    Emojix.replace_by_char(text)
  end
end
