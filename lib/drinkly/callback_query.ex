defmodule Drinkly.CallbackQuery do
  import Drinkly.Helper

  alias Drinkly.Users
  alias Drinkly.Drinks
  alias Drinkly.Metrics
  alias Drinkly.Helper

  @report_html_template Application.get_env(:drinkly, :report_html_template) ||
                          Path.absname("templates/daily_report.html")

  def execute(%{data: "remove_email", id: id, message: message}) do
    keyboard_buttons = [
      %{text: emoji(":heavy_check_mark: Delete Email"), callback_data: "confirm_remove_email"},
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
    ExGram.send_message(message.chat.id, "Are you sure about removing email", options)
  end

  def execute(%{data: "confirm_remove_email", id: id, message: message, from: user}) do
    ExGram.delete_message(message.chat.id, message.message_id)

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
  end

  def execute(%{data: "cancel_remove_email", id: id, message: message}) do
    ExGram.delete_message(message.chat.id, message.message_id)
    ExGram.answer_callback_query(id,
      text: emoji(":ok: We don't touch Your email :ok_hand_tone2:"),
      show_alert: true
    )

    ExGram.send_message(message.chat.id, "Cancelled Removing Email !")
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

  # -----O-----
  # keep this always at the end as it used for global matching
  def execute(%{id: id}) do
    text = """
    :tools: Development in Progress...:bangbang:

    :construction_worker_tone2::construction_worker_tone3: Our Engineers are working...

    :pray::pray: Sorry for inconvience :pray::pray:

    :sun_with_face: Have a Great Day :)
    """

    ExGram.answer_callback_query(id, text: emoji(text), show_alert: true)
  end

  defp create_report_task(drinks, user, title) do
    Task.start(fn ->
      report_files = Helper.generate_report(drinks, user, @report_html_template, "#{title}")
      send_report(user.id, report_files)
    end)
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
  end


  defp set_unit(unit, id, message) do
    text =
      case Metrics.update!(message.chat.id, unit: unit) do
        {:ok, _} ->
          """
          *:white_check_mark:* Your unit of measurement has been set to *#{unit}*
          /showmetrics to see your current metrics
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
  end

  defp send_report(chat_id, {pdf_file_path, html_template_file}) do
    ExGram.send_document(chat_id, {:file, pdf_file_path})
    File.rm(pdf_file_path)
    File.rm(html_template_file)
  end
end
