defmodule SocialAppApi.BlogCommentController do
  use SocialAppApi.Web, :controller

  alias SocialAppApi.BlogComment

  plug Guardian.Plug.EnsureAuthenticated, handler: SocialAppApi.AuthController

  def index(conn, %{"blog_id" => blog_id}) do
    blog_comments = BlogComment
    |> where(blog_id: ^blog_id)
    |> Repo.all
    render(conn, "index.json-api", data: blog_comments)
  end

  def index(conn, _params) do
    blog_comments = Repo.all(BlogComment)
    render(conn, "index.json-api", data: blog_comments)
  end

  def create(conn, %{"data" => %{"type" => "blog_comment",
    "attributes" => blog_comment_params, "relationships" => %{"blog_id" => blog_id}}}) do
    # get current user
    current_user = conn
    |> Guardian.Plug.current_resource

    changeset = BlogComment.changeset(%BlogComment{
      author_id: current_user.id,
      blog_id: blog_id
    }, blog_comment_params)

    case Repo.insert(changeset) do
      {:ok, blog_comment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", blog_comment_path(conn, :show, blog_comment))
        |> render("show.json-api", data: blog_comment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      blog_comment = Repo.get!(BlogComment, id)
      render(conn, "show.json-api", data: blog_comment)
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"data" => %{"type" => "blog_comment", "id" => id,
    "attributes" => blog_comment_params, "relationships" => %{"blog_id" => blog_id}}}) do
    try do
      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      blog_comment = BlogComment
      |> where(author_id: ^current_user.id, id: ^id)
      |> Repo.one!

      changeset = BlogComment.changeset(blog_comment, blog_comment_params)

      case Repo.update(changeset) do
        {:ok, blog_comment} ->
          render(conn, "show.json-api", data: blog_comment)
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

      blog_comment = BlogComment
      |> where(author_id: ^current_user.id, id: ^id)
      |> Repo.one!

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(blog_comment)

      send_resp(conn, :no_content, "")
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "401.json-api")
    end
  end
end
