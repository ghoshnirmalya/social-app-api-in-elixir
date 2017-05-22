defmodule SocialAppApi.MediaController do
  use SocialAppApi.Web, :controller

  alias SocialAppApi.Media

  plug Guardian.Plug.EnsureAuthenticated, handler: SocialAppApi.AuthController

  def index(conn, %{"user_id" => user_id}) do
    media = Media
    |> where(uploader_id: ^user_id)
    |> Repo.all
    render(conn, "index.json-api", data: media)
  end

  def index(conn, _params) do
    query = from(b in Media, order_by: [asc: b.id])
    media = Repo.all(query)

    render(conn, "index.json-api", data: media)
  end

  def create(conn, %{"data" => %{"type" => "media", "attributes" => media_params}}) do
    # get current user
    current_user = conn
    |> Guardian.Plug.current_resource

    changeset = Media.changeset(%Media{
      uploader_id: current_user.id
    }, media_params)

    case Repo.insert(changeset) do
      {:ok, media} ->
        SocialAppApi.MediaChannel.broadcast_create(media, current_user)

        conn
        |> put_status(:created)
        |> put_resp_header("location", media_path(conn, :show, media))
        |> render("show.json-api", data: media)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      media = Repo.get!(Media, id)
      render(conn, "show.json-api", data: media)
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "404.json-api")
    end
  end

  def update(conn, %{"data" => %{"type" => "media", "id" => id, "attributes" => media_params}}) do
    try do
      # get current user
      current_user = conn
      |> Guardian.Plug.current_resource

      media = Media
      |> where(uploader_id: ^current_user.id, id: ^id)
      |> Repo.one!

      changeset = Media.changeset(media, media_params)

      case Repo.update(changeset) do
        {:ok, media} ->
          SocialAppApi.MediaChannel.broadcast_update(media, current_user)

          render(conn, "show.json-api", data: media)
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

      media = Media
      |> where(uploader_id: ^current_user.id, id: ^id)
      |> Repo.one!

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(media)

      send_resp(conn, :no_content, "")
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        conn
        |> render(SocialAppApi.ErrorView, "401.json-api")
    end
  end
end
