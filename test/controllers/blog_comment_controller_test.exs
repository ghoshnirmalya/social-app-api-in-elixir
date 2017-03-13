defmodule SocialAppApi.BlogCommentControllerTest do
  use SocialAppApi.ConnCase

  alias SocialAppApi.BlogComment
  @valid_attrs %{body: "some content"}
  @invalid_attrs %{}

  defp create_test_blog_comments(user, blog) do
    # Create three blogs owned by the logged in user
    Enum.each ["first blog", "second blog", "third blog"], fn body ->
      Repo.insert! %SocialAppApi.Blog{author_id: user.id, title: "title"}
      Repo.insert! %SocialAppApi.BlogComment{author_id: user.id, blog_id: blog.id, body: body}
    end

    # Create two blogs owned by another user
    other_user = Repo.insert! %SocialAppApi.User{}
    Enum.each ["fourth blog", "fifth blog"], fn body ->
      Repo.insert! %SocialAppApi.Blog{author_id: other_user.id, title: "title"}
      Repo.insert! %SocialAppApi.BlogComment{author_id: other_user.id, blog_id: blog.id, body: body}
    end
  end

  setup %{conn: conn} do
    user = Repo.insert! %SocialAppApi.User{}
    blog = Repo.insert! %SocialAppApi.Blog{}
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)
    conn = conn
    |> put_req_header("content-type", "application/vnd.apijson")
    |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user, blog: blog}}
  end

  test "lists all entries on index", %{conn: conn, user: user, blog: blog} do
    # Build test blogs
    create_test_blog_comments user, blog
    # List of all blog_comments
    conn = get conn, blog_comment_path(conn, :index)
    assert Enum.count(json_response(conn, 200)["data"]) == 5
  end

  test "shows chosen resource", %{conn: conn, user: user, blog: blog} do
    blog_comment = Repo.insert! %BlogComment{author_id: user.id, blog_id: blog.id}
    conn = get conn, blog_comment_path(conn, :show, blog_comment)
    assert json_response(conn, 200)["data"] == %{
      "id" => to_string(blog_comment.id),
      "type" => "blog-comment",
      "attributes" => %{
        "body" => blog_comment.body
      },
      "relationships" => %{
        "blog" => %{
          "links" => %{
            "related" => "http://localhost:4001/api/v1/blogs/#{blog.id}"
          }
        },
        "author" => %{
          "links" => %{
            "related" => "http://localhost:4001/api/v1/users/#{user.id}"
          }
        }
      }
    }
  end

  test "creates and renders resource when data is valid", %{conn: conn, blog: blog} do
    conn = post conn, blog_comment_path(conn, :create), data: %{type: "blog_comment", attributes: @valid_attrs,
    relationships: %{blog_id: blog.id}}
    assert json_response(conn, 201)["data"]["id"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, blog: blog} do
    conn = post conn, blog_comment_path(conn, :create), data: %{type: "blog_comment", attributes: @invalid_attrs,
    relationships: %{blog_id: blog.id}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user, blog: blog} do
    blog_comment = Repo.insert! %BlogComment{author_id: user.id, blog_id: blog.id}
    conn = put conn, blog_comment_path(conn, :update, blog_comment), data: %{id: blog_comment.id, type: "blog_comment",
    attributes: @valid_attrs, relationships: %{blog_id: blog.id}}
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(BlogComment, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, user: user, blog: blog} do
    blog_comment = Repo.insert! %BlogComment{author_id: user.id, blog_id: blog.id}
    conn = put conn, blog_comment_path(conn, :update, blog_comment), data: %{id: blog_comment.id, type: "blog_comment",
    attributes: @invalid_attrs, relationships: %{blog_id: blog.id}}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    blog_comment = Repo.insert! %BlogComment{author_id: user.id}
    conn = delete conn, blog_comment_path(conn, :delete, blog_comment)
    assert response(conn, 204)
    refute Repo.get(BlogComment, blog_comment.id)
  end
end
