defmodule SocialAppApi.UserView do
  use SocialAppApi.Web, :view

  def render("index.json-api", %{users: users}) do
    %{data: render_many(users, SocialAppApi.UserView, "user.json-api")}
  end

  def render("show.json-api", %{user: user}) do
    %{data: render_one(user, SocialAppApi.UserView, "user.json-api")}
  end

  def render("user.json-api", %{user: user}) do
    %{
      "type" => "user",
      "attributes" => %{
        "id": user.id,
        "avatar": user.avatar,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "access_token": user.access_token,
        "auth_provider": user.auth_provider
      }
    }
  end
end
