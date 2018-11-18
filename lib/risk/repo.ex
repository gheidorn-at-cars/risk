defmodule Risk.Repo do
  use Ecto.Repo,
    otp_app: :risk,
    adapter: Ecto.Adapters.Postgres
end
