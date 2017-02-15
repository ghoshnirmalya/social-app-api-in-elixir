use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :social_app_api, SocialAppApi.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []


# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :social_app_api, SocialAppApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME_DEV"),
  password: System.get_env("DB_PASSWORD_DEV"),
  database: System.get_env("DB_NAME_DEV"),
  hostname: System.get_env("DB_HOSTNAME_DEV"),
  pool_size: 10
