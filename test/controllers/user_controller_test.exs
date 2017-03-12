defmodule SocialAppApi.UserControllerTest do
  use SocialAppApi.ConnCase

  alias SocialAppApi.User

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index" do
    user = Repo.insert! %User{}
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(user)
    {:ok, %{user: user, jwt: jwt, claims: full_claims}}
    conn = build_conn()
    |> put_req_header("authorization", "Bearer #{jwt}")
    conn = get conn, user_path(conn, :index)
    assert json_response(conn, 200)["data"] == [%{"attributes" =>
      %{"avatar" => nil,
      "email" => user.email,
      "first-name" => nil,
      "last-name" => nil},
    "id" => to_string(user.id),
    "type" => "user"}]
  end

  test "shows chosen resource" do
    user = Repo.insert! %User{}
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(user)
    {:ok, %{user: user, jwt: jwt, claims: full_claims}}
    conn = build_conn()
    |> put_req_header("authorization", "Bearer #{jwt}")
    conn = get conn, user_path(conn, :show, user)
    assert json_response(conn, 200)["data"] == %{"attributes" => %{"email" => user.email,
      "first-name" => user.first_name,
      "last-name" => user.last_name,
      "avatar" => user.avatar},
      "type" => "user",
      "id" => to_string(user.id)}
  end

  test "deletes chosen resource" do
    user = Repo.insert! %User{}
    {:ok, jwt, full_claims} = Guardian.encode_and_sign(user)
    {:ok, %{user: user, jwt: jwt, claims: full_claims}}
    conn = build_conn()
    |> put_req_header("authorization", "Bearer #{jwt}")
    conn = delete conn, user_path(conn, :delete, user)
    assert response(conn, 204)
    refute Repo.get(User, user.id)
  end
end
