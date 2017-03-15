defmodule SocialAppApi.FollowerController do
  use SocialAppApi.Web, :controller

  alias SocialAppApi.Follower

  plug Guardian.Plug.EnsureAuthenticated, handler: SocialAppApi.AuthController

  def index(conn, %{"user_id" => user_id}) do
    followers = Follower
    |> where(user_id: ^user_id)
    |> Repo.all
    render(conn, "index.json-api", data: followers)
  end

  def create(conn, %{"data" => %{"type" => "follower", "attributes" => follower_params,
    "relationships" => %{"follower_id" => follower_id}}}) do
    # get current user
    current_user = conn
    |> Guardian.Plug.current_resource

    changeset = Follower.changeset(%Follower{
      user_id: current_user.id,
      follower_id: follower_id
    }, follower_params)

    case Repo.insert(changeset) do
      {:ok, follower} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", follower_path(conn, :show, follower))
        |> render("show.json-api", data: follower)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    try do
      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      follower = Follower
      |> where(user_id: ^current_user.id, id: ^id)
      |> Repo.one!

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(follower)

      send_resp(conn, :no_content, "")
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "401.json-api")
    end
  end
end
