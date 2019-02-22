# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :breakout_pong, BreakoutPongWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "hw06.cstransky.me"],
  render_errors: [view: BreakoutPongWeb.ErrorView, accepts: ~w(html json)],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  version: Application.spec(:phoenix_distillery, :vsn),
  root: ".",
  pubsub: [name: Memory.PubSub,
          adapter: Phoenix.PubSub.PG2]

# Create and assign secret key
get_secret = fn name ->
  base = Path.expand("~/.config/phx-secrets")
  File.mkdir_p!(base)
  path = Path.join(base, name)
  unless File.exists?(path) do
    secret = Base.encode16(:crypto.strong_rand_bytes(32))
    File.write!(path, secret)
  end
  String.trim(File.read!(path))
end

config :breakout_pong, BreakoutPongWeb.Endpoint,
  secret_key_base: get_secret.("key_base")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
