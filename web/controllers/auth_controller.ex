defmodule SocialAppApi.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use SocialAppApi.Web, :controller
  plug Ueberauth

  alias SocialAppApi.User

  def request(conn, _params) do
    conn
    |> json(%{"data" =>
        %{
          "type" => "user",
          "attributes" => %{
            "status": "authentication request"
          }
        }
      })
  end

  def delete(conn, _params) do
    conn
    |> json(%{"data" =>
        %{
          "type" => "user",
          "attributes" => %{
            "status": "logged out"
          }
        }
      })
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> json(%{"data" =>
        %{
          "type" => "user",
          "attributes" => %{
            "status": "authentication failed"
          }
        }
      })
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case AuthUser.basic_info(auth) do
      {:ok, user} ->
        sign_in_user(conn, %{"user" => user})
    end

    case AuthUser.basic_info(auth) do
      {:ok, user} ->
        conn
        |> json(%{"data" =>
            %{
              "type" => "user",
              "attributes" => %{
                "avatar": user.avatar,
                "email": user.email,
                "first_name": user.first_name,
                "last_name": user.last_name,
                "access_token": user.access_token
              }
            }
          })
      {:error, reason} ->
        conn
        |> json(%{"data" =>
            %{
              "type" => "user",
              "attributes" => %{
                "status": reason
              }
            }
          })
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
          conn
          # |> json(%{access_token: user.access_token}) # Return token to the client
          |> render(SocialAppApi.UserView, "show.json-api", %{user: user})

        false ->
          # Unsuccessful login
          conn
          |> put_status(401)
          |> render(SocialAppApi.ErrorView, "401.json-api")
      end
    rescue
      e ->
        # Successful registration
        sign_up_user(conn, %{"user" => user})

        IO.inspect e # Print error to the console for debugging
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
        conn
        |> put_status(:created)
        |> render(SocialAppApi.UserView, "show.json-api", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SocialAppApi.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
