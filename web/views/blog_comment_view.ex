defmodule SocialAppApi.BlogCommentView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:body]
  has_one :author,
    link: :user_link,
    serializer: SocialAppApi.UserView,
    include: true
  has_one :blog,
    link: :blog_link,
    serializer: SocialAppApi.BlogView

  def user_link(blog_comment, conn) do
    user_url(conn, :show, blog_comment.author_id)
  end

  def blog_link(blog_comment, conn) do
    blog_url(conn, :show, blog_comment.blog_id)
  end

  def author(struct, conn) do
    case struct.author do
      %Ecto.Association.NotLoaded{} ->
        struct
        |> Ecto.assoc(:author)
      other -> other
    end
  end

  def blog(struct, conn) do
    case struct.blog do
      %Ecto.Association.NotLoaded{} ->
        struct
        |> Ecto.assoc(:blog)
      other -> other
    end
  end
end
