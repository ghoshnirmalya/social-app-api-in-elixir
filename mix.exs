defmodule SocialAppApi.Mixfile do
  use Mix.Project

  def project do
    [app: :social_app_api,
     version: "0.0.1",
     elixir: "~> 1.5.1",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     preferred_cli_env: [
      "coveralls": :test,
      "coveralls.html": :test,
      "coveralls.json": :test,
     ],
     test_coverage: [tool: ExCoveralls]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {SocialAppApi, []},
     applications: [:phoenix, :phoenix_pubsub, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :ueberauth, :oauth,
                    :ueberauth_google]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0"},
     {:phoenix_pubsub, "~> 1.0.2"},
     {:phoenix_ecto, "~> 3.2.3"},
     {:postgrex, "~> 0.13.3"},
     {:gettext, "~> 0.13.1"},
     {:cowboy, "~> 1.1.2"},
     {:cors_plug, "~> 1.3"},
     {:excoveralls, "~> 0.7.2", only: :test},
     {:oauth, "~> 1.6", github: "tim/erlang-oauth"},
     {:ueberauth, "~> 0.4"},
     {:ueberauth_google, "~> 0.6"},
     {:ja_serializer, "~> 0.12.0"},
     {:guardian, "~> 0.14.5"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
