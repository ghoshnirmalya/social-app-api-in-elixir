defmodule SocialAppApi.BlogControllerTest do
  use SocialAppApi.ConnCase

  alias SocialAppApi.Blog
  @valid_attrs %{author_id: 1, body: "some content", title: "some content"}
  @invalid_attrs %{}

  defp create_test_blogs(user) do
    # Create three blogs owned by the logged in user
    Enum.each ["first blog", "second blog", "third blog"], fn title ->
      Repo.insert! %SocialAppApi.Blog{author_id: user.id, title: title}
    end

    # Create two blogs owned by another user
    other_user = Repo.insert! %SocialAppApi.User{}
    Enum.each ["fourth blog", "fifth blog"], fn title ->
      Repo.insert! %SocialAppApi.Blog{author_id: other_user.id, title: title}
    end
   end

  setup %{conn: conn} do
    user = Repo.insert! %SocialAppApi.User{}
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)
    conn = conn
    |> put_req_header("content-type", "application/vnd.apijson")
    |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user}}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    # Build test blogs
    create_test_blogs user
    # List of all blogs
    conn = get conn, blog_path(conn, :index)
    assert Enum.count(json_response(conn, 200)["data"]) == 5
  end

  test "lists owned entries on index (author_id = user id)", %{conn: conn, user: user} do
    # Build test blogs
    create_test_blogs user
    # List of blogs owned by user
    conn = get conn, blog_path(conn, :index, user_id: user.id)
    assert Enum.count(json_response(conn, 200)["data"]) == 3
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    blog = Repo.insert! %Blog{author_id: user.id}
    conn = get conn, blog_path(conn, :show, blog)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(blog.id),
      "type" => "blog",
      "attributes" => %{
        "title" => blog.title,
        "body" => blog.body
      },
      "relationships" => %{
        "author" => %{
          "links" => %{
            "related" => "http://localhost:4001/api/v1/users/#{user.id}"
          }
        }
      }
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn, user: _user} do
    assert_error_sent 404, fn ->
      get conn, blog_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, user: _user} do
    conn = post conn, blog_path(conn, :create), blog: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, user: _user} do
    conn = post conn, blog_path(conn, :create), blog: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user} do
    blog = Repo.insert! %Blog{author_id: user.id, title: "A blog"}
    conn = put conn, blog_path(conn, :update, blog), blog: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user} do
    blog = Repo.insert! %Blog{author_id: user.id}
    conn = put conn, blog_path(conn, :update, blog), blog: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    blog = Repo.insert! %Blog{author_id: user.id }
    conn = delete conn, blog_path(conn, :delete, blog)
    assert response(conn, 204)
    refute Repo.get(Blog, blog.id)
  end
end
