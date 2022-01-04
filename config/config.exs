import Config

config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :sona,
  command_prefix: "Sona "

config :sentry,
  dsn: "https://00511a01bb134664a1e0eaa437c48670@o1106971.ingest.sentry.io/6133768",
  included_environments: [:prod],
  environment_name: Mix.env
