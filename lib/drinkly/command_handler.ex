defmodule Drinkly.CommandHandler do
  import Drinkly.{Commands, Helper}
  require Logger

  alias Drinkly.Users
  alias Drinkly.Drinks

  def handle_command({:command, :start, %{from: user, chat: chat}}, _cnt) do
    if !Users.exist?(user) do
      spawn(fn ->
        user =
          Map.new(user, fn
            {:id, id} -> {:user_id, id}
            {:first_name, id} -> {:user_name, id}
            rest -> rest
          end)

        welcome_message =
          case Users.create_user(user) do
            {:ok, user} ->
              """
              Congratulations ::bangbang:
              User Initial Setup Done :bangbang:
              """

              Users.reset_user_command(chat.id)

            {:error, error} ->
              """
              Unable to Create user Setup :(
              Sorry for inconvenience caused
              Please Try again /start
              """
          end

        message = Emojix.replace_by_char(welcome_message)

        ExGram.send_message(chat.id, message)
      end)
    end

    welcome_message = """
    Hurray :bangbang:
    Welcome to Drinkly Bot :smiley:

    This Bot is under development :tools:.

    Engineers are working on it :construction_worker:.

    Happy to serve you :exclamation:

    /help to see available commands
    """

    message = Emojix.replace_by_char(welcome_message)

    ExGram.send_message(chat.id, message)
  end

  def handle_command({:command, :report, data}, _cnt) do
    chat = data.chat

    keyboard_buttons = [
      [%{text: "Today Report", callback_data: "today_report"}],
      [%{text: "Yesterday Report", callback_data: "yesterday_report"}],
      [%{text: "Last 3 Days Report", callback_data: "last_3_days_report"}],
      [%{text: "Last 5 Days Report", callback_data: "last_5_days_report"}],
      [%{text: "One Week", callback_data: "week"}]
    ]

    text = emoji(":tickets: *Choose one of the Following Plans*")

    reply_markup = %{
      inline_keyboard: keyboard_buttons,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup, parse_mode: "markdown"]

    ExGram.send_message(chat.id, text, options)
  end

  def handle_command({:command, :setreminder, data}, _cnt) do
    chat = data.chat
    time = data.text |> String.trim()

    text =
      if time == "" do
        """
        :alarm_clock:
        *Now Enter the time*

        _Examples: 1h 2hr 30min 30m 10sec 10s_
        """
      else
        time_milli_seconds = Drinkly.Parser.parse_time(time)
        Task.start(fn -> send(Drinkly.Reminder, {:remind, time_milli_seconds, chat.id}) end)

        """
        :alarm_clock:
        Reminder - *#{time}* has been updated

        *Focus on Your Work...*

        We'll remind you after *#{time}* to drink water *:droplet:*

        Use /myreminders to show your reminders
        """

        Users.reset_user_command(chat.id)
      end

    ExGram.send_message(chat.id, emoji(text), parse_mode: "markdown")
  end

  def handle_command({:command, :email, data}, _cnt) do
    user = data.from
    chat = data.chat
    email = Users.get_user_email!(user.id)

    keyboard_buttons =
      if email do
        [
          %{text: "Remove My Email", callback_data: "remove_email"}
        ]
      else
        [
          %{text: "Add Email", callback_data: "add_email"}
        ]
      end

    text = email || emoji(":x: No email to show !")

    reply_markup = %{
      inline_keyboard: [keyboard_buttons],
      one_time_keyboard: true,
      resize_keyboard: true,
      selective: true
    }

    options = [reply_markup: reply_markup]

    ExGram.send_message(chat.id, text, options)
  end

  def handle_command({:command, :setemail, data}, _) do
    chat = data.chat
    user = data.from
    email = Users.get_user_email!(user_id: user.id)

    text =
      email
      |> setemail()
      |> emoji()

    ExGram.send_message(chat.id, text, parse_mode: "markdown")
  end

  # Just for testing
  def handle_command({:command, :echo, %{text: text, chat: chat}}, _cnt) do
    if String.trim(text) == "" do
      "Hello, Welcome !"
    else
      text
    end

    keyboard_buttons = [
      %{text: text, callback_data: text}
    ]

    reply_markup = %{
      inline_keyboard: [keyboard_buttons],
      one_time_keyboard: true,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup]

    ExGram.send_message(chat.id, text, options)
  end

  def handle_command({:command, :subscribe, %{chat: %{id: chat_id}}}, _cnt) do
    keyboard_buttons = [
      [
        %{text: "Every Hour", callback_data: "subscribe_every_hour"},
        %{text: "Monthly", callback_data: "subscribe_every_month"},
        %{text: "Daily", callback_data: "subscribe_daily"}
      ],
      [%{text: "Mute Subscription", callback_data: "subscribe_mute"}],
      [%{text: "Show Subscription", callback_data: "subscribe_show"}]
    ]

    text = emoji(":tickets: *Choose one of the Following Plans*")

    reply_markup = %{
      inline_keyboard: keyboard_buttons,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup, parse_mode: "markdown"]

    ExGram.send_message(chat_id, text, options)
  end

  def handle_command({:command, :setunit, %{chat: %{id: chat_id}}}, _cnt) do
    keyboard_buttons = [
      [%{text: "OZ - Ounce", callback_data: "set_unit_ounce"}],
      [%{text: "L - Liter", callback_data: "set_unit_liter"}]
    ]

    text = emoji(":tickets: *Choose one of the Following unit of measurement*")

    reply_markup = %{
      inline_keyboard: keyboard_buttons,
      resize_keyboard: true
    }

    options = [reply_markup: reply_markup, parse_mode: "markdown"]
    ExGram.send_message(chat_id, text, options)
  end

  def handle_command({:command, :settarget, %{chat: %{id: chat_id}}}, _cnt) do
    text = emoji(":ok: *Now enter your daily target* \n ex: 250ml, 5 ounce, 12l oz")
    ExGram.send_message(chat_id, text, parse_mode: "markdown")
  end

  def handle_command({:command, :setglass, %{chat: %{id: chat_id}}}, _cnt) do
    text = emoji(":ok: *Now enter your Glass Size* \n ex: 250ml, 5 ounce, 12l oz")
    ExGram.send_message(chat_id, text, parse_mode: "markdown")
  end

  def handle_command({:command, :mydrinks, data}, cnt) do
    handle_command({:command, :drinks, data}, cnt)
  end

  def handle_command({:command, :drink, %{text: text, chat: %{id: chat_id}}}, _cnt) do
    if empty_string?(text) do
      text = """
      Now enter the amount of water :droplet:
      Ex _250ml 2l 8oz 3glass 12ounce_
      """

      text = emoji(text)
      ExGram.send_message(chat_id, text, parse_mode: "markdown")
    else
      message = Drinks.create_drink(chat_id, text)
      ExGram.send_message(chat_id, message, parse_mode: "markdown")
    end
  end

  def handle_command({:command, :todaydrinks, %{chat: %{id: chat_id}}}, _cnt) do
    drinks = Drinkly.Drinks.today(chat_id)
    send_drinks(drinks, chat_id)
  end

  def handle_command({:command, :drinks, %{chat: %{id: chat_id}}}, _cnt) do
    drinks = Drinkly.Drinks.list_drinks(chat_id, 10).drinks
    send_drinks(drinks, chat_id)
  end

  def handle_command({:command, :showmetrics, %{chat: %{id: chat_id}}}, _cnt) do
    metric = Users.get_metric(chat_id)

    message =
      if metric do
        Map.take(metric, [:glass_size, :unit, :daily_target])

        """
        <pre>
        Glass Size    -- #{inspect(metric.glass_size)}
        Unit          -- #{inspect(metric.unit)}
        Daily Target  -- #{inspect(metric.daily_target)}
        </pre>
        """
      else
        """
        No Metric had been set 
        Use /setunit /setglass /settarget
        """
      end

    ExGram.send_message(chat_id, message, parse_mode: "html")
    Users.reset_user_command(chat_id)
  end

  def handle_command({:command, command, %{chat: %{id: chat_id}}}, _cnt)
      when command in [:listreminders, :myreminders, :deletereminder] do
    {keyboard_buttons, text} =
      case :ets.lookup(:reminders, chat_id) do
        [] ->
          text = """
          You have no *Reminders* to show
          user /setreminder to set the reminder
          """

          {nil, text}

        reminders ->
          keyboard_buttons =
            reminders
            |> Enum.chunk_every(2)
            |> Enum.map(fn chunk ->
              Enum.map(chunk, fn {_chat_id, reference, _timer, time} ->
                seconds = div(time, 1000)
                time = Drinkly.Convert.sec_to_str(seconds)
                %{text: "after-@#{time}", callback_data: "reminders" <> reference}
              end)
            end)

          text = """
          Select the Reminder
          """

          {keyboard_buttons, text}
      end

    options =
      if keyboard_buttons do
        reply_markup = %{
          inline_keyboard: keyboard_buttons,
          resize_keyboard: true
        }

        [reply_markup: reply_markup, parse_mode: "markdown"]
      else
        [parse_mode: "markdown"]
      end

    ExGram.send_message(chat_id, text, options)
  end

  def handle_command({:command, :features, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, features(), parse_mode: "markdown")
    Users.reset_user_command(chat_id)
  end

  def handle_command({:command, :about, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, about(), parse_mode: "markdown")
    Users.reset_user_command(chat_id)
  end

  def handle_command({:command, :cancel, %{chat: %{id: chat_id}}}, _cnt) do
    user = Users.get_user!(chat_id)

    message =
      if command = user.command do
        Users.reset_user_command(chat_id)

        """
        The command /#{command} has been cancelled. Anything else I can do for you?

        Send /help for a list of commands. 
        To learn more about *Drinkly* Bot, see https://drinkly.blackode.in
        """
      else
        """
        No active command to cancel. I wasn't doing anything anyway. Zzzzz...
        """
      end

    ExGram.send_message(chat_id, message, parse_mode: "markdown")
  end

  def handle_command({:command, :help, %{chat: %{id: chat_id}}}, _cnt) do
    ExGram.send_message(chat_id, help())
    Users.reset_user_command(chat_id)
  end

  def handle_command({:bot_message, from, msg}, %{name: name}) do
    Logger.info("Message from bot #{inspect(from)} to #{inspect(name)}  : #{inspect(msg)}")
    :hi
  end

  # Keep this last as it matches always
  def handle_command({:command, unknown_command, data}, _cnt) do
    chat_id = data.chat.id
    Task.start(Users, :reset_user_command, [chat_id])

    bot_commands = get_bot_commands()

    text =
      if unknown_command in bot_commands do
        get_progress_message("command")
      else
        emoji("""
        Ohoo :bangbang:
        Looks like an unrecognized command !

        #{help()}
        """)
      end

    ExGram.send_message(data.chat.id, text, parse_mode: "markdown")
  end

  defp send_drinks(drinks, chat_id) do
    text =
      if Enum.empty?(drinks) do
        """
        No Drinks to Show here
        You can add one using /drink command
        """
      else
        header = "Quantity - Unit - Date\n"

        Enum.reduce(drinks, header, fn drink, acc ->
          quantity = drink.quantity
          unit = drink.unit
          date = Timex.from_now(drink.inserted_at)
          acc <> "\n#{quantity} - #{unit} - #{date}"
        end) <> "\n \n use /drink to add a drink :)"
      end

    ExGram.send_message(chat_id, text)
    Users.reset_user_command(chat_id)
  end
end
