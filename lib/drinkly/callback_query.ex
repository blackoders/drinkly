defmodule Drinkly.CallbackQuery do
  import Drinkly.Helper

  alias Drinkly.Users

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
    ExGram.answer_callback_query(id, text: emoji(":ok: We don't touch Your email :ok_hand_tone2:"))
  end

  def execute(%{id: id}) do
    ExGram.answer_callback_query(id, text: "All is Well !!")
  end
end
