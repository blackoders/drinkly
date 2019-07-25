defmodule Drinkly.Bot do
  import Drinkly.Commands
  # replace with your bot_name here
  @bot :drinkly_bot

  use ExGram.Bot, name: @bot

  alias Drinkly.Users
  alias Drinkly.Repo
  alias Drinkly.Texts

  command("echo")
  command("start")
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
      text = emoji("Ohoo :bangbang: Please send valid command")
      answer(cnt, text)
    end
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
          %{text: "update_email"},
          %{text: "remove_email"}
        ]
      else
        [
          %{text: "add_email"},
          %{text: "remove_email"}
        ]
      end

    text = email || emoji(":x: No email to show !")

    reply_markup = %{
      keyboard: [keyboard_buttons],
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
  def handle_command({:command, :echo, %{text: t}}, cnt) do
    cnt |> answer(t)
  end

  def handle_command({:command, :chat, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, help(), parse_mode: "markdown")
  end

  def handle_command({:command, :subscribe, %{chat: %{id: _chat_id}}}, cnt) do
    answer(cnt, "We will take care of you... :)")
  end

  def handle_command({:command, :features, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, features(), parse_mode: "markdown")
  end

  def handle_command({:command, :about, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, about(), parse_mode: "markdown")
  end

  def handle_command({:bot_message, from, msg}, %{name: name}) do
    Logger.info("Message from bot #{inspect(from)} to #{inspect(name)}  : #{inspect(msg)}")
    :hi
  end

  def handle_command(msg, _) do
    IO.puts("Unknown message #{inspect(msg)}")
  end

  def emoji(text) do
    Emojix.replace_by_char(text)
  end

  def update_user_command(id, command) do
    command = to_string(command)
    user = Repo.get_by!(Users.User, user_id: id)
    Users.update_user(user, %{command: command})
    Repo.get_by!(Users.User, user_id: id)
  end
end
