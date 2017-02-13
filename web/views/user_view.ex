defmodule SocialAppApi.UserView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:avatar, :email, :first_name, :last_name, :access_token, :auth_provider]
end
