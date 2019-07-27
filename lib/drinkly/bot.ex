defmodule Drinkly.Bot do
  import Drinkly.{Commands, Helper}
  # replace with your bot_name here
  @bot :drinkly_bot

  use ExGram.Bot, name: @bot

  alias Drinkly.{Users, Repo, Texts, CallbackQuery}

  command("echo")
  command("start")
  command("remind")
  command("set_glass_size")
  command("help")
  command("subscribe")
  command("about")
  command("features")
  command("email")
  command("add_email")

  middleware(ExGram.Middleware.IgnoreUsername)

  require Logger

  def handle({:command, command, %{from: user}} = data, cnt) do
    spawn(fn -> update_user_command(user.id, command) end)
    handle_command(data, cnt)
  end

  def handle({:text, _text, %{from: user}} = data, cnt) do
    user = Users.get_user_by!(user_id: user.id)
    user_command = user.command

    text_function =
      if user_command do
        user_command |> String.to_atom()
      else
        nil
      end

    if text_function in Drinkly.module_functions(Texts) do
      apply(Texts, text_function, [data])
    else
      text =
        emoji(
          "Ohoo :bangbang: Please send valid command \n command /help to see available commands"
        )

      answer(cnt, text)
    end
  end

  def handle({:callback_query, data}, _cnt) do
    apply(CallbackQuery, :execute, [data])
  end

  def handle_command({:command, :remind, data}, _cnt) do
    chat = data.chat
    time = data.text |> String.trim()
    time = if time == "", do: "5sec", else: time

    time = Drinkly.Parser.parse_time(time)

    Task.start(fn -> send(Drinkly.Reminder, {:remind, time, chat.id}) end)

    ExGram.send_message(chat.id, "Reminder has been set \n Focus on Work \n
      We'll remind you when to drink water")
  end

  def handle_command({:command, :start, %{from: user}}, cnt) do
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

    This Bot is under development :pencil:.

    Engineers are working on it :construction_worker:.

    Happy to serve you :exclamation:
    """

    message = Emojix.replace_by_char(welcome_message)

    answer(cnt, message)
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

  def handle_command({:command, :add_email, data}, _) do
    chat = data.chat
    user = data.from
    email = Users.get_user_email!(user_id: user.id)

    text =
      email
      |> add_email()
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

  def handle_command(msg, _) do
    IO.puts("Unknown message #{inspect(msg)}")
  end

  def update_user_command(id, command) do
    command = to_string(command)
    user = Repo.get_by!(Users.User, user_id: id)
    Users.update_user(user, %{command: command})
    Repo.get_by!(Users.User, user_id: id)
  end
end
