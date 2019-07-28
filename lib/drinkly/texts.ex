defmodule Drinkly.Texts do
  alias ExGram, as: Bot
  alias Drinkly.Users
  import Drinkly.Validator

  def setemail({:text, email, data}) do
    chat_id = data.chat.id

    text =
      if validate_email?(email) do
        user = Users.get_user_by!(user_id: data.from.id)

        case Users.update_user(user, %{email: email, command: nil}) do
          {:ok, user} ->
            "#{user.email} has been updated !!"

          {:error, _changeset} ->
            "Error in adding email: #{email}"
        end
      else
        "INVALID EMAIL \n Please enter valid email"
      end

    Bot.send_message(chat_id, text, reply_markup: %{remove_keyboard: true})
  end
end
