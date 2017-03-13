defmodule SocialAppApi.BlogCommentView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body]
  has_one :author, link: :user_link
  has_one :blog, link: :blog_link

  def user_link(blog_comment, conn) do
    user_url(conn, :show, blog_comment.author_id)
  end

  def blog_link(blog_comment, conn) do
    blog_url(conn, :show, blog_comment.blog_id)
  end
end
