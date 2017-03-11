defmodule SocialAppApi.BlogView do
  use SocialAppApi.Web, :view
  use JaSerializer.PhoenixView

  attributes [:title, :body, :author_id]
end
