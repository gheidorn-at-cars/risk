# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :risk,
  ecto_repos: [Risk.Repo]

# Configures the endpoint
config :risk, RiskWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cq7wUvL6CzTLe3CRG9iYb15QIOCbV1c/58+Pt4Qr/c/5+1eElSlo8oErWEsI63oo",
  render_errors: [view: RiskWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Risk.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "1WTLvuIqlND19WGW/WiBxOhrT8S4dDAreqyu74GGbezFkaZ41XGoiKOjEokqkVu+"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix,
  json_library: Jason,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
