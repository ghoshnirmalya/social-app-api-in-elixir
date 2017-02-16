defmodule SocialAppApi.UserView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:avatar, :email, :first_name, :last_name, :auth_provider]
end
