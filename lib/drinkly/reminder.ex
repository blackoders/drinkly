defmodule Drinkly.Reminder do
  @moduledoc """
  Responsible of handling my job's schedule.

  * Runs job on start and every minute thereafter.
  """
  import Drinkly.Helper, only: [emoji: 1]
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_info({:remind, time, chat_id}, state) do
    schedule_remind_job(time, chat_id)
    {:noreply, state}
  end

  def handle_info({:send_message, chat_id}, state) do
    text = """
    *It's Time to Drink Water*
    *Stay Healthy*
    """
    message = emoji(text)
    ExGram.send_message(chat_id, message, [parse_mode: "markdown"])
    {:noreply, state}
  end

  defp schedule_remind_job(time, chat_id) do
    Process.send_after(self(), {:send_message, chat_id}, time)
  end

end
