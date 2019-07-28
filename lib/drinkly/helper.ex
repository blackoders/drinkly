defmodule Drinkly.Helper do
  def emoji(text) do
    Emojix.replace_by_char(text)
  end

  @doc """
  It gets you the Utc Date Time
  """
  def today_date() do
    DateTime.utc_now() |> DateTime.to_date()
  end

  @doc """
  It gives you the today NaiveDateTime now
  """
  def now() do
    DateTime.utc_now() |> DateTime.to_naive()
  end
end
