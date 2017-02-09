use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :social_app_api, SocialAppApi.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :social_app_api, SocialAppApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "nirmalyaghosh",
  password: "",
  database: "social_app_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
