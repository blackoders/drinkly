defmodule Drinkly.Texts do
  alias ExGram, as: Bot
  alias Drinkly.Users
  alias Drinkly.Metrics
  import Drinkly.Validator
  import Drinkly.Helper

  def setemail({:text, email, data}) do
    chat_id = data.chat.id

    text =
      if validate_email?(email) do
        user = Users.get_user_by!(user_id: data.chat.id)

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

  def settarget({:text, target, data}) do
    error_message = """
    *:x:* Looks like something went wrong
    Try again /settarget
    """

    message =
      if valid_measure?(target) do
        case Metrics.update!(data.chat.id, daily_target: target) do
          {:ok, _} ->
            """
            *:white_check_mark:* Your Daily target has been set to *#{target}*
            /showmetrics to see your current metrics
            """

          {:error, _changeset} ->
            error_message
        end
      else
        error_message
      end

    ExGram.send_message(data.chat.id, emoji(message), parse_mode: "markdown")
  end

  def setglass({:text, glass_size, data}) do
    error_message = """
    *:x:* Looks like something went wrong
    Try again /setglass
    """

    message =
      if valid_measure?(glass_size) do
        case Metrics.update!(data.chat.id, glass_size: glass_size) do
          {:ok, _} ->
            """
            *:white_check_mark:* Your Glass size has been set to *#{glass_size}*
            /showmetrics to see your current metrics
            """

          {:error, _changeset} ->
            error_message
        end
      else
        error_message
      end

    ExGram.send_message(data.chat.id, emoji(message), parse_mode: "markdown")
  end

  def drink({:text, text, data}) do
    chat_id = data.chat.id
    message = Drinkly.Drinks.create_drink(chat_id, text)

    Bot.send_message(chat_id, message <> "/drinks", parse_mode: "markdown")
  end
end
