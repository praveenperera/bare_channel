use Mix.Config

config :bare_channel, BareChannelWeb.Endpoint,
  url: [host: "example.com", port: 80],
  server: true,
  root: ".",
  check_origin: false

# Do not print debug messages in production
config :logger, level: :warn
