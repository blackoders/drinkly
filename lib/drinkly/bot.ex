defmodule Drinkly.Bot do

  #replace with your bot_name here
  @bot :drinkly_bot

  use ExGram.Bot, name: @bot

  command("echo")
  command("start")
  command("subscribe")

  middleware(ExGram.Middleware.IgnoreUsername)

  require Logger

  #Just for testing
  def handle({:command, :echo, %{text: t}}, cnt) do
    cnt |> answer(t)
  end

  def handle({:command, :subscribe, %{chat: %{id: chat_id}}}, cnt) do

    # ExGram.send_photo(chat_id, {:file, "files/images/welcome.png"})
    answer(cnt, "We will take care of you... :)")
  end

  def handle({:command, :start, %{chat: %{id: chat_id}}}, cnt) do
    ExGram.send_message(chat_id, "Welcome to Drinkly Bot :)")
    ExGram.send_photo(chat_id, {:file, "files/images/welcome.png"})
  end

  def handle({:bot_message, from, msg}, %{name: name}) do
    Logger.info("Message from bot #{inspect(from)} to #{inspect(name)}  : #{inspect(msg)}")
    :hi
  end

  def handle(msg, _) do
    IO.puts("Unknown message #{inspect(msg)}")
  end
end
