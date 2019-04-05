use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :risk, RiskWeb.Endpoint,
  http: [port: 4000],
  server: false

# Print only warnings and errors during test
config :logger, level: :info

# Configure your database
config :risk, Risk.Repo,
  username: "postgres",
  password: "postgres",
  database: "risk_dev",
  hostname: "localhost",
  port: 5432,
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox
