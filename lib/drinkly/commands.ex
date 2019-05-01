defmodule Drinkly.Commands do

  def description do
    "Drinkly Bot helps us to track the quantity of water we drink and remind us to drink water in right time."
  end

  def features do
    data = "
    Features
    --------

    ⁃ Set goal amount of daily drinking water and track it.

    ⁃ Log amount of daily drinking water.

    ⁃ Check glasses of water drunk each day.

    ⁃ Customize volume of each glass of water.

    ⁃ Customize how much of water you drink each time, 1/4 glass, 1/2 glass or A glass.

    ⁃ Plan drinking schedule and it will remind you when it’s time.

    ⁃ Histogram to show the amount of your one day’s, recent one week’s and one month’s amount of drinking water.

    ⁃ Show amount of glasses of water you have drunk one day on the icon.

    ⁃ Email the data of date, amount of water to anyone you would like.

    ⁃ Supports Dropbox backup and restore.
  "
  end
end
