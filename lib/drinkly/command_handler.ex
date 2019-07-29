defmodule Drinkly.CommandHandler do
  import Drinkly.{Commands, Helper}
  require Logger

  alias Drinkly.Users

  def handle_command({:command, :report, data}, _cnt) do
    chat = data.chat

    keyboard_buttons = [
      [%{text: "Today Report", callback_data: "today_report"}],
      [%{text: "Yesterday Report", callback_data: "yesterday_report"}],
      [%{text: "Last 3 Days Report", callback_data: "last_3_days_report"}],
      [%{text: "Last 5 Days Report", callback_data: "last_5_days_report"}]
    ]

    text = emoji(":tickets: *Choose one of the Following Plans*")

    reply_markup = %{
      inline_keyboard: keyboard_buttons,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup, parse_mode: "markdown"]

    ExGram.send_message(chat.id, text, options)
  end

  def handle_command({:command, :setreminder, data}, _cnt) do
    chat = data.chat
    time = data.text |> String.trim()
    time = if time == "", do: "5sec", else: time

    time_milli_seconds = Drinkly.Parser.parse_time(time)

    Task.start(fn -> send(Drinkly.Reminder, {:remind, time_milli_seconds, chat.id}) end)

    text = """
    :alarm_clock: 
    Reminder - *#{time}* has been updated
    *Focus on Your Work...* 
    We'll remind you after *#{time}* to drink water *:droplet:*
    """

    ExGram.send_message(chat.id, emoji(text), parse_mode: "markdown")

  end

  def handle_command({:command, :start, %{from: user, chat: chat}}, _cnt) do
    spawn(fn ->
      user =
        user
        |> Enum.map(fn
          {:id, id} -> {:user_id, id}
          {:username, id} -> {:user_name, id}
          rest -> rest
        end)
        |> Enum.into(%{})

      Users.create_user(user)
    end)

    welcome_message = """
    Hurray :bangbang: 
    Welcome to Drinkly Bot :smiley:

    This Bot is under development :tools:.

    Engineers are working on it :construction_worker:.

    Happy to serve you :exclamation:
    """

    message = Emojix.replace_by_char(welcome_message)

    ExGram.send_message(chat.id, message)
    # ExGram.send_photo(chat_id, {:file, "files/images/welcome.png"})
  end

  def handle_command({:command, :email, data}, _cnt) do
    user = data.from
    chat = data.chat
    email = Users.get_user_email!(user.id)

    keyboard_buttons =
      if email do
        [
          %{text: "Remove My Email", callback_data: "remove_email"}
        ]
      else
        [
          %{text: "Add Email", callback_data: "add_email"}
        ]
      end

    text = email || emoji(":x: No email to show !")

    reply_markup = %{
      inline_keyboard: [keyboard_buttons],
      one_time_keyboard: true,
      resize_keyboard: true,
      selective: true
    }

    options = [reply_markup: reply_markup]

    ExGram.send_message(chat.id, text, options)
  end

  def handle_command({:command, :setemail, data}, _) do
    IO.inspect("setemail")
    chat = data.chat
    user = data.from
    email = Users.get_user_email!(user_id: user.id)

    text =
      email
      |> setemail()
      |> emoji()

    ExGram.send_message(chat.id, text, parse_mode: "markdown")
  end

  # Just for testing
  def handle_command({:command, :echo, %{text: text, chat: chat}}, _cnt) do
    if String.trim(text) == "" do
      "Hello, Welcome !"
    else
      text
    end

    keyboard_buttons = [
      %{text: text, callback_data: text}
    ]

    reply_markup = %{
      inline_keyboard: [keyboard_buttons],
      one_time_keyboard: true,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup]

    ExGram.send_message(chat.id, text, options)
  end

  def handle_command({:command, :subscribe, %{chat: %{id: chat_id}}}, _cnt) do
    keyboard_buttons = [
      [
        %{text: "Every Hour", callback_data: "subscribe_every_hour"},
        %{text: "Monthly", callback_data: "subscribe_every_month"},
        %{text: "Daily", callback_data: "subscribe_daily"}
      ],
      [%{text: "Mute Subscription", callback_data: "subscribe_mute"}],
      [%{text: "Show Subscription", callback_data: "subscribe_show"}]
    ]

    text = emoji(":tickets: *Choose one of the Following Plans*")

    reply_markup = %{
      inline_keyboard: keyboard_buttons,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup, parse_mode: "markdown"]

    ExGram.send_message(chat_id, text, options)
  end

  def handle_command({:command, :setunit, %{chat: %{id: chat_id}}}, _cnt) do
    keyboard_buttons = [
      [%{text: "OZ - Ounce", callback_data: "set_unit_ounce"}],
      [%{text: "L - Liter", callback_data: "set_unit_liter"}]
    ]
    text = emoji(":tickets: *Choose one of the Following unit of measurement*")

    reply_markup = %{
      inline_keyboard: keyboard_buttons,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup, parse_mode: "markdown"]
    ExGram.send_message(chat_id, text, options) 
  end

  def handle_command({:command, :features, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, features(), parse_mode: "markdown")
  end

  def handle_command({:command, :about, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, about(), parse_mode: "markdown")
  end

  def handle_command({:command, :help, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, help())
  end


  def handle_command({:bot_message, from, msg}, %{name: name}) do
    Logger.info("Message from bot #{inspect(from)} to #{inspect(name)}  : #{inspect(msg)}")
    :hi
  end

  # Keep this last as it matches always
  def handle_command({:command, _unknown_command, data}, _cnt) do
    text =
      emoji("""
      Ohoo :bangbang:

      Looks like you sent an unrecognized command

      #{help()}
      """)

    ExGram.send_message(data.chat.id, text, parse_mode: "markdown")
  end
end
