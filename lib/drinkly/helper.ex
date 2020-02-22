defmodule Drinkly.Helper do
  @root_dir File.cwd!()
  @files_dir Path.join(@root_dir, "files")
  @commands_file Path.join(@files_dir, "commands.md")

  def emoji(text) do
    Emojix.replace_by_char(text)
  end

  @doc """
  It gets you the Utc Date Time
  """
  def today_date() do
    DateTime.utc_now() |> DateTime.to_date()
  end

  @doc """
  It gives you the today NaiveDateTime now
  """
  def now() do
    DateTime.utc_now() |> DateTime.to_naive()
  end

  def generate_report(drinks, user, report_html_template, type) do
    IO.inspect(report_html_template, label: "----------report tempalte----------")

    now = now() |> to_string()
    name = user.first_name
    extension = "html"

    file_name = Enum.join([name, type, now], "_")

    report_output_file_name = "#{file_name}.#{extension}"

    report_string = EEx.eval_file(report_html_template, drinks: drinks, user_name: name)
    templates_dir = Path.join(:code.priv_dir(:drinkly), "assets/templates")

    IO.inspect(templates_dir, label: "----------templtedir----------")

    html_template_file =
      templates_dir
      |> Path.absname()
      |> Path.join(report_output_file_name)

    {:ok, report_file} = File.open(html_template_file, [:write])

    IO.write(report_file, report_string)
    File.close(report_file)

    pdfs_dir = Path.join(:code.priv_dir(:drinkly), "assets/pdfs")

    pdf_file_path = Path.join(pdfs_dir, "#{file_name}.pdf")

    PuppeteerPdf.Generate.from_file(html_template_file, pdf_file_path, timeout: 100_000)

    {pdf_file_path, html_template_file}
  end

  @doc """
  Four possibel ways of deleting a message
  """
  def delete_message({:ok, message}) do
    ExGram.delete_message(message.chat.id, message.message_id)
  end

  def delete_message({chat_id, message_id}) do
    ExGram.delete_message(chat_id, message_id)
  end

  def delete_message(message) when is_map(message) do
    ExGram.delete_message(message.chat.id, message.message_id)
  end

  def delete_message(chat_id, message_id) do
    ExGram.delete_message(chat_id, message_id)
  end

  def empty_string?(string) do
    string = String.trim(string)
    string == ""
  end

  def get_bot_commands() do
    file = Application.get_env(:drinly, :commands_file, @commands_file)

    file
    |> File.stream!()
    |> Enum.map(&String.split(&1, "-", trim: true))
    |> Enum.map(&List.first/1)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_atom/1)
  end

  def get_progress_message(type \\ "command") do
    message = """
    We are sorry for disappointing now :(

    This #{type} is under development :tools:.

    Engineers are working on it :construction_worker:.

    Happy to serve you :exclamation:

    Please visit again :)

    Thank you :pray:
    """

    Emojix.replace_by_char(message)
  end
end
