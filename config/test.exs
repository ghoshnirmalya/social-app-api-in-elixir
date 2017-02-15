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
  username: System.get_env("DB_USERNAME_TEST"),
  password: System.get_env("DB_PASSWORD_TEST"),
  database: System.get_env("DB_NAME_TEST"),
  hostname: System.get_env("DB_HOSTNAME_TEST"),
  pool: Ecto.Adapters.SQL.Sandbox
