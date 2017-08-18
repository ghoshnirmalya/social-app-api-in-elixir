defmodule SocialAppApi.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use SocialAppApi.Web, :controller

  alias SocialAppApi.User
  alias Ueberauth.Auth

  plug Ueberauth

  def delete(conn, _params) do
    # Sign out the user
    conn
    |> put_status(200)
    |> Guardian.Plug.sign_out(conn)
  end

  def callback(conn, %{
    "data" => %{
      "type" => "auth",
      "attributes" => %{
        "token" => token,
        "email" => email,
        "first_name" => first_name,
        "last_name" => last_name,
        "avatar" => avatar
      }
    }
  }) do
    sign_in_user(conn, %{
      "data" => %{
        "type" => "auth",
        "attributes" => %{
          "token" => token,
          "email" => email,
          "first_name" => first_name,
          "last_name" => last_name,
          "avatar" => avatar
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

  def sign_in_user(conn, %{
    "data" => %{
      "type" => "auth",
      "attributes" => %{
        "token" => token,
        "email" => email,
        "first_name" => first_name,
        "last_name" => last_name,
        "avatar" => avatar
      }
    }
  }) do
    try do
      # Attempt to retrieve exactly one user from the DB, whose
      # email matches the one provided with the login request
      user = User
      |> where(email: ^email)
      |> Repo.one!

      cond do
        true ->
          # Successful login
          # Encode a JWT
          { :ok, jwt, _ } = Guardian.encode_and_sign(user, :token)

          auth_conn = Guardian.Plug.api_sign_in(conn, user)
          jwt = Guardian.Plug.current_token(auth_conn)
          {:ok, claims} = Guardian.Plug.claims(auth_conn)

          auth_conn
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

        # Sign the user up
        sign_up_user(conn, %{
          "data" => %{
            "type" => "auth",
            "attributes" => %{
              "token" => token,
              "email" => email,
              "first_name" => first_name,
              "last_name" => last_name,
              "avatar" => avatar
            }
          }
        })
    end
  end

  def sign_up_user(conn, %{
    "data" => %{
      "type" => "auth",
      "attributes" => %{
        "token" => token,
        "email" => email,
        "first_name" => first_name,
        "last_name" => last_name,
        "avatar" => avatar
      }
    }
  }) do
    changeset = User.changeset %User{}, %{
      email: email,
      avatar: avatar,
      first_name: first_name,
      last_name: last_name,
      auth_provider: "Google"
    }

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

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> render(SocialAppApi.ErrorView, "401.json-api")
  end
end
