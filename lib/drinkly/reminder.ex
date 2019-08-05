defmodule Drinkly.Reminder do
  @moduledoc """
  Responsible of handling my job's schedule.

  * Runs job on start and every minute thereafter.
  """
  import Drinkly.Helper, only: [emoji: 1]
  use GenServer

  def start_link(_) do
    case GenServer.start_link(__MODULE__, nil, name: __MODULE__) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Process.link(pid)
        {:ok, pid}

      :ignore ->
        :ignore
    end
  end

  def init(_) do
    :ets.match_object(:reminders, {:_, :_, :_})
    |> Enum.each(fn {chat_id, reference, time} ->
      time = Drinkly.Parser.parse_time(time)
      schedule_remind_job(chat_id, reference, time)
    end)

    {:ok, %{}}
  end

  def handle_cast({:add_reminder, {chat_id, timer, time}}, state) do
    state =
      if state[chat_id] do
        user_reminders =
          state
          |> get_in([chat_id])
          |> Map.put(timer, time)

        Map.put(state, chat_id, user_reminders)
      else
        Map.put(chat_id, timer, time)
      end

    {:noreply, state}
  end

  def handle_info({:remind, time, chat_id}, state) do
    {reference, timer} = schedule_remind_job(chat_id, time)
    :ets.insert(:reminders, {chat_id, reference, timer, time})
    {:noreply, state}
  end

  def handle_info({:send_message, chat_id, reference, _time}, state) do
    :ets.match_delete(:reminders, {chat_id, reference, :_, :_})

    text = """
    *It's Time to Drink Water*
    *Stay Healthy*
    Use /setreminder to add another reminder
    :pray: THANK YOU :pray:
    """

    message = emoji(text)

    ExGram.send_message(chat_id, message, parse_mode: "markdown")

    {:noreply, state}
  end

  defp schedule_remind_job(chat_id, time, reference \\ nil) do
    reference = reference || inspect(make_ref())
    timer = Process.send_after(self(), {:send_message, chat_id, reference, time}, time)
    {reference, timer}
  end
end
