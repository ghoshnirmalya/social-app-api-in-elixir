defmodule SocialAppApi.MediaView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :description, :url]
  has_one :uploader, link: :user_link

  def user_link(media, conn) do
    user_url(conn, :show, media.uploader_id)
  end
end
