defmodule SocialAppApi.BlogControllerTest do
  use SocialAppApi.ConnCase

  alias SocialAppApi.Blog
  @valid_attrs %{author: "some content", body: "some content", title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, blog_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    blog = Repo.insert! %Blog{}
    conn = get conn, blog_path(conn, :show, blog)
    assert json_response(conn, 200)["data"] == %{"id" => blog.id,
      "title" => blog.title,
      "body" => blog.body,
      "author" => blog.author}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, blog_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, blog_path(conn, :create), blog: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Blog, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, blog_path(conn, :create), blog: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    blog = Repo.insert! %Blog{}
    conn = put conn, blog_path(conn, :update, blog), blog: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Blog, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    blog = Repo.insert! %Blog{}
    conn = put conn, blog_path(conn, :update, blog), blog: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    blog = Repo.insert! %Blog{}
    conn = delete conn, blog_path(conn, :delete, blog)
    assert response(conn, 204)
    refute Repo.get(Blog, blog.id)
  end
end
