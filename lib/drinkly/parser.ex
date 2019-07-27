defmodule Drinkly.Parser do
  @seconds ~w(sec seconds second s)
  @hours ~w(hour hours hr h)
  @minutes ~w(min minutes minute m)
  def parse_time(time) when is_binary(time) do
    time = String.trim(time)
    {time, unit} = Integer.parse(time)
    unit = String.trim(unit)

    unit_value =
      case unit do
        sec when sec in @seconds ->
          1

        min when min in @minutes ->
          60

        hour when hour in @hours ->
          60 * 60

        "" ->
          1

        _ ->
          raise Drinkly.Exception.InvalidTime
      end

    time * unit_value * 1000
  end
end
