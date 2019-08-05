defmodule Drinkly.Calendar do
  def create_callback_data(action, year, month, day) do
    Enum.join([";", action, str(year), str(month), str(day)], ";")
  end

  def separate_callback_data(data) do
    String.split(data, ";", trim: true)
  end

  @doc """
  Create an inline keyboard with the provided year and month
  :param int year: Year to use in the calendar, if None the current year is used.
  :param int month: Month to use in the calendar, if None the current month is used.
  :return: Returns the InlineKeyboardMarkup object with the calendar.
  """
  def create_calendar(year \\ nil, month \\ nil) do
    now = Timex.today()
    year = year || now.year
    month = month || now.month
    month_name = Timex.month_name(month)
    data_ignore = create_callback_data(IGNORE, year, month, 0)

    # First row - Month and Year
    row = [%{text: "#{month_name} #{year}", callback_data: data_ignore} | []]

    keyboard = [row | []]
    # Second row - Week Days

    row =
      for day <- ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"] do
        %{text: day, callback_data: data_ignore}
      end

    keyboard = [row | keyboard]

    my_calendar = month_calendar(year, month)

    weeks_keyboard =
      for week <- my_calendar do
        for day <- week do
          if(day) do
            callback_data = create_callback_data("DAY", year, month, day)
            %{text: "#{day}", callback_data: callback_data}
          else
            %{text: " ", callback_data: data_ignore}
          end
        end
      end

    keyboard =
      Enum.reduce(weeks_keyboard, keyboard, fn day_keyboard, acc ->
        [day_keyboard | acc]
      end)

    # Last row - Buttons
    prev_month_button = %{
      text: "<",
      callback_data: create_callback_data("PREV-MONTH", year, month, 1)
    }

    empty_button = %{text: " ", callback_data: data_ignore}

    next_month_button = %{
      text: ">",
      callback_data: create_callback_data("NEXT-MONTH", year, month, 1)
    }

    row = [prev_month_button, empty_button, next_month_button]

    keyboard = [row | keyboard]
    Enum.reverse(keyboard)
  end

  def month_calendar(year \\ nil, month \\ nil) do
    date =
      if year && month do
        {:ok, date} = Date.new(year, month, 1)
        date
      else
        Timex.today()
      end

    week_days =
      date
      |> Timex.beginning_of_month()
      |> Timex.weekday()
      |> Kernel.-(1)

    days_in_month = Timex.days_in_month(date)

    range_of_days = 1..days_in_month

    list_of_days = Enum.to_list(range_of_days)

    calendar_days =
      case week_days do
        0 ->
          list_of_days

        n ->
          []
          nil_list = Enum.map(1..n, fn _ -> nil end)
          nil_list ++ list_of_days
      end

    nil_list = Enum.map(1..6, fn _ -> nil end)
    Enum.chunk_every(calendar_days, 7, 7, nil_list)
  end

  def str(value), do: to_string(value)
end
