defmodule Drinkly.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Drinkly.Repo
  alias Drinkly.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by!(options)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_by!(options), do: Repo.get_by!(User, options)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    changeset = User.changeset(%User{}, attrs)

    if changeset.valid? do
      Repo.insert(changeset)
    else
      Logger.error("Error in Chageset!")
      Logger.info("#{inspect(changeset.errors)}")
      {:error, :nousercreated}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def delete_all_users() do
    Repo.delete_all(User)
  end

  @doc """
  Gets a  user email by user_id.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_email!(123)
      "hello@drinkly.com"

      iex> get_user_email!(user_id: 123)
      "hello@drinkly.com"

      iex> get_user_email!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_email!(user_id: user_id) do
    get_user_email!(user_id)
  end

  def get_user_email!(user_id) do
    Repo.get_by!(User, user_id: user_id).email
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

  iex> change_user(user)
  %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def get_metric(user_id) do
    user_id
    |> get_user!()
    |> Repo.preload(:metric)
    |> Map.get(:metric)
  end

  def update_user_command(user_id, command) do
    command = to_string(command)

    user_id
    |> get_user!()
    |> update_user(%{command: command})
  end

  def reset_user_command(user_id) do
    user_id
    |> get_user!()
    |> update_user(%{command: nil})
  end

  def exist?(%{user_id: id}) do
    exist?(id)
  end

  def exist?(%{id: id}) do
    exist?(id)
  end

  def exist?(id) do
    !!Repo.get(User, id)
  end
end
