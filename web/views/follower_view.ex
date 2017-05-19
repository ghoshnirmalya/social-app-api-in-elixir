defmodule SocialAppApi.FollowerView do
  use SocialAppApi.Web, :view

  use JaSerializer.PhoenixView

  attributes [:follower_id]
end
