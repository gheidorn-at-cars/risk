use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :risk, RiskWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :risk, Risk.Repo,
  username: "postgres",
  password: "postgres",
  # password: "cars123",
  database: "risk_dev",
  hostname: "localhost",
  port: 5432,
  # port: 5433,
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox
