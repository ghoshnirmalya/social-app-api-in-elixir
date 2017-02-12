defmodule AuthUser do
  @moduledoc """
  Retrieve the user information from an auth request
  """

  alias Ueberauth.Auth

  def basic_info(%Auth{} = auth) do
    {:ok,
      %{
        name: auth.info.name,
        avatar: auth.info.image,
        email: auth.info.email,
        first_name: auth.info.first_name,
        last_name: auth.info.last_name,
        access_token: auth.extra.raw_info.token.access_token
      }
    }
  end
end
