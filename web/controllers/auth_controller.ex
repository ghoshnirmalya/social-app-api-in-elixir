defmodule SocialAppApi.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use SocialAppApi.Web, :controller
  plug Ueberauth

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
        conn
        |> json(%{"data" =>
            %{
              "type" => "user",
              "attributes" => %{
                "name": user.name,
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
end
