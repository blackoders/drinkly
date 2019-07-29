defmodule Drinkly.Helper do
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

    now = now() |> to_string()
    name = user.first_name
    extension = "html"

    file_name = Enum.join([name, type, now], "_")

    report_output_file_name = "#{file_name}.#{extension}"

    report_string = EEx.eval_file(report_html_template, drinks: drinks, user_name: name)

    html_template_file =
      "templates"
      |> Path.absname()
      |> Path.join(report_output_file_name)

    {:ok, report_file} = File.open(html_template_file, [:write])

    IO.write(report_file, report_string)
    File.close(report_file)

    pdf_file_path = Path.absname("pdfs") |> Path.join("#{file_name}.pdf")

    PuppeteerPdf.Generate.from_file(html_template_file, pdf_file_path)

    {pdf_file_path, html_template_file}

  end

  def delete_message({:ok, message}) do
    ExGram.delete_message(message.chat.id, message.message_id)
  end

end
