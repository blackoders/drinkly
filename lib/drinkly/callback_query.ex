defmodule Drinkly.CallbackQuery do
  import Drinkly.Helper

  alias Drinkly.Users
  alias Drinkly.Drinks
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

  def execute(%{data: "confirm_remove_email", id: id, message: _message, from: user}) do
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
  end

  def execute(%{data: "cancel_remove_email", id: id}) do
    ExGram.answer_callback_query(id,
      text: emoji(":ok: Whte don't touch Your email :ok_hand_tone2:")
    )
  end

  def execute(%{data: "today_report", id: id, message: message, from: user}) do
    chat_id = message.chat.id
    user_id = user.id

    text = """
    Your *Daily Water Drinking* report is in progress
    We'll send a `PDF` file after generation
    """

    ExGram.send_message(chat_id, text, parse_mode: "markdown")
    ExGram.answer_callback_query(id)
    ExGram.delete_message(chat_id, message.message_id)

    drinks =
      user_id
      |> Drinks.today()
      |> Enum.with_index(1)

    Task.start(fn ->
      now = Helper.now() |> to_string()
      name = user.first_name
      type = "today_report"
      extension = "html"

      file_name = Enum.join([name, type, now], "_")

      report_output_file_name = "#{file_name}.#{extension}"

      report_string = EEx.eval_file(@report_html_template, drinks: drinks, user_name: name)

      html_template_file =
        "templates"
        |> Path.absname()
        |> Path.join(report_output_file_name)

      {:ok, report_file} = File.open(html_template_file, [:write])

      IO.write(report_file, report_string)
      File.close(report_file)

      pdf_file_path = Path.absname("pdfs") |> Path.join("#{file_name}.pdf")

      PuppeteerPdf.Generate.from_file(html_template_file, pdf_file_path)

      ExGram.send_document(chat_id, {:file, pdf_file_path})

      File.rm(pdf_file_path)
      File.rm(html_template_file)
    end)
  end

  def execute(%{id: id}) do
    text = """
    :tools: Development in Progress...:bangbang:

    :construction_worker_tone2::construction_worker_tone3: Our Engineers are working...

    :pray::pray: Sorry for inconvience :pray::pray:

    :sun_with_face: Have a Great Day :)
    """

    ExGram.answer_callback_query(id, text: emoji(text), show_alert: true)
  end
end
