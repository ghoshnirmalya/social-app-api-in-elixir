defmodule SocialAppApi.BlogController do
  use SocialAppApi.Web, :controller

  alias SocialAppApi.Blog

  plug Guardian.Plug.EnsureAuthenticated, handler: SocialAppApi.AuthController

  def index(conn, %{"user_id" => user_id}) do
    blogs = Blog
    |> where(author_id: ^user_id)
    |> Repo.all
    render(conn, "index.json-api", data: blogs)
  end

  def index(conn, _params) do
    blogs = Repo.all(Blog)
    render(conn, "index.json-api", data: blogs)
  end

  def create(conn, %{"data" => %{"type" => "blog", "attributes" => blog_params}}) do
    # get current user
    current_user = conn
    |> Guardian.Plug.current_resource

    changeset = Blog.changeset(%Blog{
      author_id: current_user.id
    }, blog_params)

    case Repo.insert(changeset) do
      {:ok, blog} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", blog_path(conn, :show, blog))
        |> render("show.json-api", data: blog)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      blog = Repo.get!(Blog, id)
      render(conn, "show.json-api", data: blog)
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"data" => %{"type" => "blog", "id" => id, "attributes" => blog_params}}) do
    try do
      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      blog = Blog
      |> where(author_id: ^current_user.id, id: ^id)
      |> Repo.one!

      changeset = Blog.changeset(blog, blog_params)

      case Repo.update(changeset) do
        {:ok, blog} ->
          SocialAppApi.BlogChannel.broadcast_change(blog, current_user)

          render(conn, "show.json-api", data: blog)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "401.json-api")
    end
  end

  def delete(conn, %{"id" => id}) do
    try do
      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      blog = Blog
      |> where(author_id: ^current_user.id, id: ^id)
      |> Repo.one!

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(blog)

      send_resp(conn, :no_content, "")
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "401.json-api")
    end
  end
end
