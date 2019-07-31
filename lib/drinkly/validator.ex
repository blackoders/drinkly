defmodule Drinkly.Validator do
  @email_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
  @units ~w(l ml liter litre ounce oz)
  @doc """
  validates the email""

  ## Examples
  #
      iex> Drinkly.Validator.validate_email?("hello@blackode.in")
      true
      iex> Drinkly.Validator.validate_email?("helloblackode.in")
      false
      iex> Drinkly.Validator.validate_email?("hello@blackodein")
      false
      iex> Drinkly.Validator.validate_email?("helloblackodein")
      false
  """
  def validate_email?(email) when is_binary(email) do
    Regex.match?(@email_regex, email)
  end

  def valid_measure?(value) do
    {quantity, unit} = Integer.parse(value)
    unit = String.trim(unit)
    quantity > 0 && unit in @units
  end
end
