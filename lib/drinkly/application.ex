defmodule Drinkly.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
     token = Application.get_env(:ex_gram, :token)
    # List all child processes to be supervised
    children = [
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
    end
  end
end
