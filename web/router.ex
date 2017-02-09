defmodule SocialAppApi.Router do
  use SocialAppApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SocialAppApi do
    pipe_through :api
  end
end
