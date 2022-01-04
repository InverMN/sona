import Config

config :nostrum,
  token: System.fetch_env!("SONA_DISCORD_BOT_TOKEN")

config :logger,
  level: :warning

config :sona,
  command_prefix: System.fetch_env!("SONA_COMMAND_PREFIX"),
  youtube_data_api_key: System.fetch_env!("SONA_YOUTUBE_DATA_API_KEY")
