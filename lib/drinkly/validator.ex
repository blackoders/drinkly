defmodule Drinkly.Validator do
  @email_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
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
end
