defmodule Drinkly.Commands do
  def description do
    "Drinkly Bot helps us to track the quantity of water we drink and remind us to drink water in right time."
  end

  def features do
    "
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

  def about do
    "Drinkly Bot helps us to track the quantity of water we drink and remind us to drink water in right time, but you have to tell when to remind in a day."
  end

  def setemail(email) do
    """
    Your Current Email: *#{email || "NULL"}*

    Now Please Enter Your Email. 

    *WARNING* *:warning:*
    ~~~~~~
    If email already exists, the *NEW* email overrides *OLD* one


    Now Enter Your Email 
    example: `hello@email.com`
    """
  end

  def help do
    """
    I can help you track quantity of water 
    you drink and remind you to drink water
    in right time.

    You can control me by sending these 
    commands:

    /about - Bot Description.
    /echo - just echo I LOVE YOU
    /email - Shows your email
    /setemail - change your email for reports
    /features - Bot Features

    *Reminders*
    /setreminder - set a reminder
    /listreminders - get a list of your reminders
    /deletereminder - display reminders to remove

    *Drinks*
    /drink - add a drink to your today
    /listdrinks - show Top 10 Drinks
    /todaydrinks - shows today drinks

    *Metrics*
    /setglass - change your glass size
    /settarget - change your daily target
    /setunit - change your unit of measurement
    /showmetrics - display all metrics

    *Others*
    /help - Commands & Description
    /report - get your drinking report
    /start - Initiating Bot :)
    /subscribe - add a subscription

    """
  end
end
