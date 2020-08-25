defmodule RumblWeb.UserController do
  use RumblWeb, :controller
  
  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  # Showing the user details
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end

   # user_controller.change1.ex
  def new(conn, _params) do
    changeset = Account.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end
end