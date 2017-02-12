# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :social_app_api,
  ecto_repos: [SocialAppApi.Repo]

# Configures the endpoint
config :social_app_api, SocialAppApi.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "swM9UavsN9Og2l4YuFCxuY9JkJbdP4MzMJ1S6kDAjmiandGNxHNbc9OMI7upMBmf",
  render_errors: [view: SocialAppApi.ErrorView, accepts: ~w(json)],
  pubsub: [name: SocialAppApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Change the json response type to json-api
config :phoenix, :format_encoders,
  "json-api": Poison

config :plug, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

# Ueberauth Config for oauth
config :ueberauth, Ueberauth,
  base_path: "/api/v1/auth",
  providers: [
    google: { Ueberauth.Strategy.Google, [] },
    identity: { Ueberauth.Strategy.Identity, [
        callback_methods: ["POST"],
        uid_field: :username,
        nickname_field: :username,
      ] },
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("GOOGLE_REDIRECT_URI")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
