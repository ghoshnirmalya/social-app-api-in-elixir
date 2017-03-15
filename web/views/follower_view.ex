defmodule SocialAppApi.FollowerView do
  use SocialAppApi.Web, :view

  use JaSerializer.PhoenixView

  attributes [:follower_id]
  has_one :follower, link: :user_link

  def user_link(follower, conn) do
    user_url(conn, :show, follower.follower_id)
  end
end
