defmodule Drinkly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    create_ets_tables()
    token = Application.get_env(:ex_gram, :token)
    # List all child processes to be supervised
    children = [
      {Http, port: 8080},
      Drinkly.Scheduler,
      Drinkly.Repo,
      Drinkly.Reminder,
      ExGram,
      {Drinkly.Bot, [method: :polling, token: token]}

      # Starts a worker by calling: Drinkly.Worker.start_link(arg)
      # {Drinkly.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Drinkly.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _} = ok ->
        Logger.info("Started Drinkly Bot")
        ok

      error ->
        Logger.error("Error in Starting Drinkly Bot")
        Logger.error("#{inspect(error)}")
    end
  end

  defp create_ets_tables() do
    :ets.new(:reminders, [:set, :public, :named_table, :duplicate_bag])
  end
end
