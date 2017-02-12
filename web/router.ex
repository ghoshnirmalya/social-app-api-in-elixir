defmodule SocialAppApi.Router do
  use SocialAppApi.Web, :router

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/api/v1", SocialAppApi do
    pipe_through :api
  end

  scope "/api/v1/auth", SocialAppApi do
    pipe_through :api

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end
end
