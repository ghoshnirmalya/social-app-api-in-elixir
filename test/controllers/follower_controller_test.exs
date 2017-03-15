defmodule SocialAppApi.FollowerControllerTest do
  use SocialAppApi.ConnCase

  alias SocialAppApi.Follower
  @valid_attrs %{}

  setup %{conn: conn} do
    user = Repo.insert! %SocialAppApi.User{}
    follower = Repo.insert! %SocialAppApi.Follower{}
    { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)
    conn = conn
    |> put_req_header("content-type", "application/vnd.apijson")
    |> put_req_header("authorization", "Bearer #{jwt}")

    {:ok, %{conn: conn, user: user, follower: follower}}
  end

  test "creates and renders resource when data is valid", %{conn: conn, user: user} do
    conn = post conn, follower_path(conn, :create), data: %{type: "follower", attributes: @valid_attrs,
    relationships: %{follower_id: user.id}}
    assert json_response(conn, 201)["data"]["id"]
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    follower = Repo.insert! %Follower{
      user_id: user.id,
      follower_id: user.id
    }
    conn = delete conn, follower_path(conn, :delete, follower)
    assert response(conn, 204)
    refute Repo.get(Follower, follower.id)
  end
end
