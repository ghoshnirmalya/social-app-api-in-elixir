defmodule SocialAppApi.BlogView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :body]
  has_one :author,
    link: :user_link,
    serializer: SocialAppApi.UserView,
    include: true

  def user_link(blog, conn) do
    user_url(conn, :show, blog.author_id)
  end
end
