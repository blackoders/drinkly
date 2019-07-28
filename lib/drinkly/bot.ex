defmodule Drinkly.Bot do
  import Drinkly.{Commands, Helper}
  # replace with your bot_name here
  @bot :drinkly_bot

  use ExGram.Bot, name: @bot

  alias Drinkly.{Users, Texts, CallbackQuery}

  command("echo")
  command("start")
  command("setreminder")
  command("setglass")
  command("help")
  command("subscribe")
  command("report")
  command("about")
  command("features")
  command("email")
  command("setemail")
  command("setunit")
  command("settarget")
  command("showmetrics")
  command("deletereminder")
  command("listreminders")
  command("drink")
  command("todaydrinks")

  middleware(ExGram.Middleware.IgnoreUsername)

  def handle({:command, command, %{from: user}} = data, cnt) do
    spawn(fn -> update_user_command(user.id, command) end)
    Drinkly.CommandHandler.handle_command(data, cnt)
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
        emoji("""
        Ohoo :bangbang:

        Looks like you sent an unrecognized command

        #{help()}
        """)

      answer(cnt, text, parse_mode: "markdown")
    end
  end

  def handle({:callback_query, data}, _cnt) do
    apply(CallbackQuery, :execute, [data])
  end

  def update_user_command(user_id, command) do
    command = to_string(command)

    user_id
    |> Users.get_user!()
    |> Users.update_user(%{command: command})
  end
end
