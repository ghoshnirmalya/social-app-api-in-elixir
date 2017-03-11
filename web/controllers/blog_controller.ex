defmodule SocialAppApi.BlogController do
  use SocialAppApi.Web, :controller

  alias SocialAppApi.Blog

  plug Guardian.Plug.EnsureAuthenticated, handler: SocialAppApi.AuthController

  def index(conn, _params) do
    blogs = Repo.all(Blog)
    render(conn, "index.json-api", data: blogs)
  end

  def create(conn, %{"blog" => blog_params}) do
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
    blog = Repo.get!(Blog, id)
    render(conn, "show.json-api", data: blog)
  end

  def update(conn, %{"id" => id, "blog" => blog_params}) do
    try do
      blog = Repo.get!(Blog, id)

      # get author_id
      author_id = blog.author_id

      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      if author_id === current_user.id do
        # do the operation if the current_user is the author
        changeset = Blog.changeset(blog, blog_params)

        case Repo.update(changeset) do
          {:ok, blog} ->
            render(conn, "show.json-api", data: blog)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
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
    try do
      blog = Repo.get!(Blog, id)
      # get author_id
      author_id = blog.author_id

      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      if author_id === current_user.id do
        # Here we use delete! (with a bang) because we expect
        # it to always work (and if it does not, it will raise).
        Repo.delete!(blog)

        send_resp(conn, :no_content, "")
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
end
