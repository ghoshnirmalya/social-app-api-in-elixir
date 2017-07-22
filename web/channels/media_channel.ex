defmodule SocialAppApi.MediaChannel do
  use SocialAppApi.Web, :channel

  import SocialAppApi.Router.Helpers
  alias SocialAppApi.Endpoint

  def join("media", payload, socket) do
    {:ok, "Joined media", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def broadcast_create(media, user) do
    payload = %{
      "id" => to_string(media.id),
      "type" => "media",
      "attributes" => %{
        "url" => media.url,
        "name" => media.name,
        "description" => media.description
      },
      "relationships" => %{
        "uploader" => %{
          "links" => %{
            "related" => "#{user_url(Endpoint, :index)}/#{user.id}"
          }
        }
      }
    }

    SocialAppApi.Endpoint.broadcast("media", "app/MediaLibraryPage/HAS_NEW_MEDIA", payload)
  end

  def broadcast_update(media, user) do
    payload = %{
      "id" => to_string(media.id),
      "type" => "media",
      "attributes" => %{
        "url" => media.url,
        "name" => media.name,
        "description" => media.description
      },
      "relationships" => %{
        "uploader" => %{
          "links" => %{
            "related" => "#{user_url(Endpoint, :index)}/#{user.id}"
          }
        }
      }
    }

    SocialAppApi.Endpoint.broadcast("media", "app/MediaLibraryPage/HAS_UPDATED_MEDIA", payload)
  end
end
