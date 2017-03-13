defmodule SocialAppApi.Router do
  use SocialAppApi.Web, :router

  pipeline :api_auth do
    plug :accepts, ["json", "json-api"]
    plug JaSerializer.Deserializer
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug JaSerializer.Deserializer
  end

  scope "/api/v1", SocialAppApi do
    pipe_through :api

    # auth
    delete "/logout", AuthController, :delete

    # users
    resources "/users", UserController, except: [:new, :edit] do
      get "/blogs", BlogController, :index, as: :blogs
      get "/current", UserController, :current, as: :current_user
    end

    # blogs
    resources "/blogs", BlogController, except: [:new, :edit] do
      get "/comments", BlogCommentController, :index, as: :blog_comments
    end

    #blog comments
    resources "/blog_comments", BlogCommentController, except: [:new, :edit]
  end

  scope "/api/v1/auth", SocialAppApi do
    pipe_through :api_auth

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end
end
