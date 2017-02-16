defmodule SocialAppApi.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use SocialAppApi.Web, :controller
  plug Ueberauth

  alias SocialAppApi.User

  def request(_params) do
  end

  def delete(conn, _params) do
    # Sign out the user
    conn
    |> put_status(200)
    |> json(%{"data" =>
        %{
          "type" => "user",
          "attributes" => %{
            "status": "log out"
          }
        }
      })
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    # This callback is called when the user denies the app to get the
    # data from the oauth provider
    conn
    |> put_status(401)
    |> render(SocialAppApi.ErrorView, "401.json-api")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case AuthUser.basic_info(auth) do
      {:ok, user} ->
        sign_in_user(conn, %{"user" => user})
    end

    case AuthUser.basic_info(auth) do
      {:ok, user} ->
        conn
        |> render(SocialAppApi.UserView, "show.json-api", %{data: user})
      {:error} ->
        conn
        |> put_status(401)
        |> render(SocialAppApi.ErrorView, "401.json-api")
    end
  end

  defp sign_in_user(conn, %{"user" => user}) do
    try do
      # Attempt to retrieve exactly one user from the DB, whose
      # email matches the one provided with the login request
      user = User
      |> where(email: ^user.email)
      |> Repo.one!

      cond do
        true ->
          # Successful login
          # Encode a JWT
          { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)

          conn
          |> put_resp_header("authorization", "Bearer #{jwt}")
          |> json(%{access_token: jwt}) # Return token to the client

        false ->
          # Unsuccessful login
          conn
          |> put_status(401)
          |> render(SocialAppApi.ErrorView, "401.json-api")
      end
    rescue
      e ->
        IO.inspect e # Print error to the console for debugging

        # Successful registration
        sign_up_user(conn, %{"user" => user})
    end
  end

  defp sign_up_user(conn, %{"user" => user}) do
    changeset = User.changeset %User{}, %{email: user.email,
      avatar: user.avatar,
      first_name: user.first_name,
      last_name: user.last_name,
      access_token: user.access_token,
      auth_provider: "google"}

    case Repo.insert changeset do
      {:ok, user} ->
        # Encode a JWT
        { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)

        conn
          |> put_resp_header("authorization", "Bearer #{jwt}")
          |> json(%{access_token: jwt}) # Return token to the client
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render(SocialAppApi.ErrorView, "422.json-api")
    end
  end

  def unauthenticated(conn, params) do
  conn
    |> put_status(401)
    |> render(SocialAppApi.ErrorView, "401.json-api")
  end

  def unauthorized(conn, params) do
    conn
    |> put_status(403)
    |> render(SocialAppApi.ErrorView, "403.json-api")
  end

  def already_authenticated(conn, params) do
    conn
    |> put_status(200)
    |> render(SocialAppApi.ErrorView, "200.json-api")
  end

  def no_resource(conn, params) do
    conn
    |> put_status(404)
    |> render(SocialAppApi.ErrorView, "404.json-api")
  end
end
