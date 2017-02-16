defmodule SocialAppApi.Router do
  use SocialAppApi.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
    plug JaSerializer.Deserializer
  end

  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug JaSerializer.Deserializer
  end

  scope "/api/v1", SocialAppApi do
    pipe_through :api_auth

    resources "/users", UserController, except: [:new, :edit]
    get "/user/current", UserController, :current, as: :current_user
    delete "/logout", AuthController, :delete
  end

  scope "/api/v1/auth", SocialAppApi do
    pipe_through :api

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end
end
