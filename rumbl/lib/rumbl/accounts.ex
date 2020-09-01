defmodule Rumbl.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Rumbl.Repo
  alias Rumbl.Accounts.User

  #def list_users do
  #  [
  #    %User{id: "1", name: "José", username: "josevalim"},
  #    %User{id: "2", name: "Bruce", username: "redrapids"},
  #    %User{id: "3", name: "Chris", username: "chrismccord"}    
  #  ]
  #end

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
end
