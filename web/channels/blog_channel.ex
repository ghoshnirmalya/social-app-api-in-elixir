defmodule SocialAppApi.BlogChannel do
  use SocialAppApi.Web, :channel

  import SocialAppApi.Router.Helpers
  alias SocialAppApi.Endpoint

  def join("blogs", payload, socket) do
    {:ok, "Joined blogs", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def broadcast_create(blog, user) do
    payload = %{
      "id" => to_string(blog.id),
      "type" => "blog",
      "attributes" => %{
        "title" => blog.title,
        "body" => blog.body
      },
      "relationships" => %{
        "author" => %{
          "links" => %{
            "related" => "#{user_url(Endpoint, :index)}/#{user.id}"
          }
        }
      }
    }

    SocialAppApi.Endpoint.broadcast("blogs", "app/blogs-page/HAS_NEW_BLOGS", payload)
  end

  def broadcast_update(blog, user) do
    payload = %{
      "id" => to_string(blog.id),
      "type" => "blog",
      "attributes" => %{
        "title" => blog.title,
        "body" => blog.body
      },
      "relationships" => %{
        "author" => %{
          "links" => %{
            "related" => "#{user_url(Endpoint, :index)}/#{user.id}"
          }
        }
      }
    }

    SocialAppApi.Endpoint.broadcast("blogs", "app/blogs-page/HAS_UPDATED_BLOGS", payload)
  end
end
