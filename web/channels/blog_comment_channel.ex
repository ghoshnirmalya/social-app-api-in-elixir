defmodule SocialAppApi.BlogCommentChannel do
  use SocialAppApi.Web, :channel

  import SocialAppApi.Router.Helpers
  alias SocialAppApi.Endpoint

  def join("comments", payload, socket) do
    {:ok, "Joined comments", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   broadcast! socket, "ping", %{body: payload}
  #   {:reply, {:ok, payload}, socket}
  # end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (blog:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end

  # Add authorization logic here as required.
  # defp authorized?(_payload) do
  #   true
  # end

  def broadcast_change(comment, user, blog_id) do
    payload = %{
      "id" => to_string(comment.id),
      "type" => "blog-comment",
      "attributes" => %{
        "body" => comment.body
      },
      "relationships" => %{
        "blog" => %{
          "links" => %{
            "related" => "#{blog_url(Endpoint, :index)}/#{blog_id}"
          }
        },
        "author" => %{
          "links" => %{
            "related" => "#{user_url(Endpoint, :index)}/#{user.id}"
          }
        }
      }
    }

    SocialAppApi.Endpoint.broadcast("comments", "app/BlogPage/HAS_UPDATED_OR_NEW_COMMENTS", payload)
  end
end
