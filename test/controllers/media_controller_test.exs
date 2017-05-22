defmodule SocialAppApi.MediaControllerTest do
  use SocialAppApi.ConnCase

  alias SocialAppApi.Media
  @valid_attrs %{description: "some content", name: "some content", url: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, media_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    media = Repo.insert! %Media{}
    conn = get conn, media_path(conn, :show, media)
    assert json_response(conn, 200)["data"] == %{"id" => media.id,
      "name" => media.name,
      "description" => media.description,
      "url" => media.url,
      "uploader_id" => media.uploader_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, media_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, media_path(conn, :create), media: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Media, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, media_path(conn, :create), media: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    media = Repo.insert! %Media{}
    conn = put conn, media_path(conn, :update, media), media: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Media, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    media = Repo.insert! %Media{}
    conn = put conn, media_path(conn, :update, media), media: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    media = Repo.insert! %Media{}
    conn = delete conn, media_path(conn, :delete, media)
    assert response(conn, 204)
    refute Repo.get(Media, media.id)
  end
end
