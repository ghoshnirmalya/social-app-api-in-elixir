defmodule SocialAppApi.UserController do
  use SocialAppApi.Web, :controller

  alias SocialAppApi.User

  plug Guardian.Plug.EnsureAuthenticated, handler: SocialAppApi.AuthController

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.json-api", data: users)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.json-api", data: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    try do
      # get data for the user in the request
      user = Repo.get!(User, id)

      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      if user.id === current_user.id do
        # do the update operation if the user is authorized
        changeset = User.changeset(user, user_params)

        case Repo.update(changeset) do
          {:ok, user} ->
            render(conn, "show.json-api", data: user)
          {:error, changeset} ->
            conn
            |> put_status(422)
            |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
        end
      else
        conn
        |> render(SocialAppApi.ErrorView, "401.json-api")
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "404.json-api")
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    send_resp(conn, :no_content, "")
  end

  def current(conn, _) do
    user = conn
    |> Guardian.Plug.current_resource

    conn
    |> render(SocialAppApi.UserView, "show.json-api", data: user)
  end
end
