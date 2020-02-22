defmodule Drinkly.CallbackQuery do
  import Drinkly.Helper

  alias Drinkly.Users
  alias Drinkly.Drinks
  alias Drinkly.Metrics
  alias Drinkly.Helper

  require Logger

  def execute(%{data: "add_email", id: id, message: message, from: user}) do
    Users.update_user_command(user.id, "setemail")

    text = "Now Enter the email or /cancel to cancel adding email"

    ExGram.answer_callback_query(id)
    delete_message(message)
    ExGram.send_message(message.chat.id, text, [])
  end

  def execute(%{data: "remove_email", id: id, message: message, from: user}) do
    email = Users.get_user_email!(user.id)

    keyboard_buttons = [
      %{
        text: emoji(":heavy_check_mark: Delete Email #{email}"),
        callback_data: "confirm_remove_email"
      },
      %{text: emoji(":x: NO Keep Email"), callback_data: "cancel_remove_email"}
    ]

    reply_markup = %{
      inline_keyboard: [keyboard_buttons],
      one_time_keyboard: true,
      resize_keyboard: true,
      selective: true
    }

    options = [reply_markup: reply_markup]

    ExGram.answer_callback_query(id)
    delete_message(message)

    text = """
    Are you sure about removing email?
    -> #{email}
    """

    ExGram.send_message(message.chat.id, text, options)
  end

  def execute(%{data: "confirm_remove_email", id: id, message: message, from: user}) do
    delete_message(message)

    query_reply =
      try do
        Users.get_user_by!(user_id: user.id)
        |> Users.update_user(%{email: nil})
        |> case do
          {:ok, _} ->
            [
              show_alert: true,
              text: emoji(":heavy_check_mark: Email Removed Successfully ")
            ]

          {:error, _} ->
            [
              show_alert: true,
              text: emoji(":x: Email Removing Failed ")
            ]
        end
      rescue
        Ecto.NoResultsError ->
          [
            show_alert: true,
            text: emoji(":x: No User Found in DB")
          ]
      end

    ExGram.answer_callback_query(id, query_reply)
    ExGram.send_message(message.chat.id, query_reply)
    Users.reset_user_command(message.chat.id)
  end

  def execute(%{data: "cancel_remove_email", id: id, message: message}) do
    delete_message(message)

    ExGram.answer_callback_query(id,
      text: emoji(":ok: We don't touch Your email :ok_hand_tone2:"),
      show_alert: true
    )

    ExGram.send_message(message.chat.id, "Cancelled Removing Email !")
    Users.reset_user_command(message.chat.id)
  end

  def execute(%{data: "set_unit_ounce", id: id, message: message}) do
    set_unit("ounce", id, message)
  end

  def execute(%{data: "set_unit_liter", id: id, message: message}) do
    set_unit("liter", id, message)
  end

  def execute(%{data: "today_report", id: id, message: message}) do
    user_id = chat_id = message.chat.id
    user = message.chat

    send_pre_report_message(message, chat_id, id, "Today")

    drinks =
      user_id
      |> Drinks.today()
      |> Enum.with_index(1)

    create_report_task(drinks, user, "Today")
  end

  def execute(%{data: "yesterday_report", id: id, message: message}) do
    user_id = chat_id = message.chat.id
    user = message.chat

    send_pre_report_message(message, chat_id, id, "Yesterday")

    drinks =
      user_id
      |> Drinks.yesterday()
      |> Enum.with_index(1)

    create_report_task(drinks, user, "Yesterday")
  end

  def execute(%{data: "last_3_days_report", id: id, message: message}) do
    user_id = chat_id = message.chat.id
    user = message.chat

    send_pre_report_message(message, chat_id, id, "Last 3 Days")

    drinks =
      user_id
      |> Drinks.last_3_days()
      |> Enum.with_index(1)

    create_report_task(drinks, user, "Last 3 Days")
  end

  def execute(%{data: "last_5_days_report", id: id, message: message}) do
    user_id = chat_id = message.chat.id
    user = message.chat

    send_pre_report_message(message, chat_id, id, "Last 3 Days")

    drinks =
      user_id
      |> Drinks.last_3_days()
      |> Enum.with_index(1)

    create_report_task(drinks, user, "Last 3 Days")
  end

  def execute(%{data: "week", id: id, message: message}) do
    user_id = chat_id = message.chat.id
    user = message.chat

    send_pre_report_message(message, chat_id, id, "Week")

    drinks =
      user_id
      |> Drinks.week()
      |> Enum.with_index(1)

    create_report_task(drinks, user, "Week")
  end

  def execute(%{data: ";" <> calendar_data, id: id, message: message}) do
    chat_id = message.chat.id
    [action, year, month, day] = String.split(calendar_data, ";", trim: true)
    year = String.to_integer(year)
    month = String.to_integer(month)
    day = String.to_integer(day)

    {:ok, current_date} = Date.new(year, month, day)

    ExGram.answer_callback_query(id)

    case action do
      "IGNORE" ->
        ExGram.answer_callback_query(id)

      "DAY" ->
        Helper.delete_message(message)
        ExGram.send_message(chat_id, to_string(current_date))

      "PREV-MONTH" ->
        present_date = Timex.shift(current_date, months: -1)

        reply_markup = %{
          inline_keyboard:
            Drinkly.Calendar.create_calendar(present_date.year, present_date.month),
          one_time_keyboard: true,
          resize_keyboard: true,
          selective: true
        }

        options = [
          reply_markup: reply_markup,
          chat_id: chat_id,
          message_id: message.message_id,
          inline_message_id: id
        ]

        ExGram.edit_message_reply_markup(options)

      "NEXT-MONTH" ->
        present_date = Timex.shift(current_date, months: 1)

        reply_markup = %{
          inline_keyboard:
            Drinkly.Calendar.create_calendar(present_date.year, present_date.month),
          one_time_keyboard: true,
          resize_keyboard: true,
          selective: true
        }

        options = [
          reply_markup: reply_markup,
          chat_id: chat_id,
          message_id: message.message_id,
          inline_message_id: id
        ]

        ExGram.edit_message_reply_markup(options)

      _ ->
        ExGram.answer_callback_query(id, text: emoji(":x: Somethig Went Wrong"), show_alert: true)
    end
  end

  def execute(%{data: "reminders" <> reference, id: id, message: message}) do
    chat_id = message.chat.id

    keyboard = [%{text: "Delete reminder", callback_data: "deletereminder#{reference}"}]

    reply_markup = %{
      inline_keyboard: [keyboard],
      one_time_keyboard: true,
      resize_keyboard: true,
      selective: true
    }

    options = [
      reply_markup: reply_markup
    ]

    ExGram.answer_callback_query(id)
    Drinkly.Helper.delete_message(message)

    ExGram.send_message(chat_id, "Select the action", options)
  end

  def execute(%{data: "deletereminder" <> reference, id: id, message: message}) do
    chat_id = message.chat.id

    keyboard = [
      %{text: "Confirm Delete Reminder", callback_data: "confirmdeletereminder#{reference}"}
    ]

    reply_markup = %{
      inline_keyboard: [keyboard],
      one_time_keyboard: true,
      resize_keyboard: true,
      selective: true
    }

    options = [
      reply_markup: reply_markup
    ]

    ExGram.answer_callback_query(id)
    Drinkly.Helper.delete_message(message)

    text = """
    One Step away to delete
    Just Confirm by pressing the button
    :warning: Once deleted cannot rollback
    """

    ExGram.send_message(chat_id, emoji(text), options)
  end

  def execute(%{data: "confirmdeletereminder" <> reference, id: id, message: message}) do
    chat_id = message.chat.id
    ExGram.answer_callback_query(id)
    Drinkly.Helper.delete_message(message)

    [{chat_id, _, timer, _} = reminder] =
      :ets.match_object(:reminders, {chat_id, reference, :_, :_})

    :ets.delete_object(:reminders, reminder)

    Process.cancel_timer(timer)

    text = """
    :heavy_check_mark: Removed Reminder Successfully :)
    """

    ExGram.send_message(chat_id, emoji(text))
    Users.reset_user_command(message.chat.id)
  end

  # -----O-----
  # keep this always at the end as it used for global matching
  def execute(%{id: id} = data) do
    IO.inspect(data, label: "data of a person")

    text = """
    :tools: Development in Progress...:bangbang:

    :construction_worker_tone2::construction_worker_tone3: Our Engineers are working...

    :pray::pray: Sorry for inconvience :pray::pray:

    :sun_with_face: Have a Great Day :)
    """

    ExGram.answer_callback_query(id, text: emoji(text), show_alert: true)
  end

  defp create_report_task(drinks, user, title) do
<<<<<<< HEAD
    try do
      Task.start(fn ->
        report_html_template = Path.join(:code.priv_dir(:drinkly), "assets/templates/report.html")
        report_files = Helper.generate_report(drinks, user, report_html_template, "#{title}")
        send_report(user.id, report_files)
      end)
    catch 
      err -> 
        Logger.error("#{inspect err}")
    end
=======
    IO.inspect(Path.absname("templates/daily_report.html"), label: "templates")

    Task.start(fn ->
      report_files = Helper.generate_report(drinks, user, @report_html_template, "#{title}")
      send_report(user.id, report_files)
    end)
>>>>>>> develop
  end

  defp send_pre_report_message(message, chat_id, message_id, title) do
    text = """
    Your *#{title} Water Drinking* report is in progress
    We'll send a `PDF` file after generation
    Please wait ...
    """

    ExGram.send_message(chat_id, text, parse_mode: "markdown")
    ExGram.answer_callback_query(message_id)
    ExGram.delete_message(chat_id, message.message_id)
    Users.reset_user_command(message.chat.id)
  end

  defp set_unit(unit, id, message) do
    text =
      case Metrics.update!(message.chat.id, unit: unit) do
        {:ok, _} ->
          """
          *:white_check_mark:* Your unit of measurement has been set to *#{unit}*
            Use /showmetrics to see your current metrics
          """

        {:error, _changeset} ->
          """
          *:x:* Looks like something went wrong
          Try again /setunit
          """
      end

    ExGram.answer_callback_query(id)
    Helper.delete_message(message)
    ExGram.send_message(message.chat.id, emoji(text), parse_mode: "markdown")
    Users.reset_user_command(message.chat.id)
  end

  defp send_report(chat_id, {pdf_file_path, html_template_file}) do
    if File.exists?(pdf_file_path) do
      ExGram.send_document(chat_id, {:file, pdf_file_path})
      File.rm(pdf_file_path)
      File.rm(html_template_file)
    else
      text =
        """
        We are unable to generate PDF :cry:
        Sorry for the issue :(
        """
        |> emoji()

      ExGram.send_message(chat_id, text, [])
    end
  end
end
