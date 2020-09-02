defmodule Rumbl.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Rumbl.Repo
  alias Rumbl.Accounts.User

  def get_user(id) do
    Repo.get(User, id)
  end

  # Raises an  Ecto.NotFoundError when looking up a user doesn't exist
  def get_user!(id) do 
    Repo.get!(User, id)
  end

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def list_users do
    Repo.all(User)
  end

  # accounts.change2.ex
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  # accounts.change3.ex
  def create_user(attrs \\ %{}) do
    %User{} # start with an empty user
    |> User.changeset(attrs) # applies a changeset
    |> Repo.insert() # insert it to the Repo
  end

  # accounts.change1.ex
  def change_registration(%User{} = user, params) do
    User.registration_changeset(user, params)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # accounts.change2.ex
  def authenticate_by_username_and_pass(username, given_pass) do
    user = get_user_by(username: username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
