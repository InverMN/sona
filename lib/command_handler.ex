defmodule Sona.CommandHandler do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Cache.GuildCache
  alias Nostrum.Voice

  require Logger

  @command_prefix Application.fetch_env!(:sona, :command_prefix)
  @youtube_data_api_key Application.fetch_env!(:sona, :youtube_data_api_key)

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def timeout_until_ready(guild_id) do
    unless Voice.ready?(guild_id) do
      Process.sleep(100)
      timeout_until_ready(guild_id)
    end
  end

  def handle_event({:MESSAGE_CREATE, %Nostrum.Struct.Message{content: @command_prefix <> " " <> command} = message, _websocket_state}) do
    case command do
      "wbijaj" ->
        case get_voice_channel_of_msg(message) do
          nil ->
            Api.create_message(message.channel_id, "Yyyy... Tylko gdzie? Pierwsze wejdź na jakiś kanał głosowy, a potem mnie wołaj")
          voice_channel_id ->
            Api.create_message(message.channel_id, "Jasne!")
            Voice.join_channel(message.guild_id, voice_channel_id)
        end
      "wypierdalaj" ->
        Api.create_message!(message.channel_id, "Aha.")
        Voice.leave_channel(message.guild_id)
        Voice.stop(message.guild_id)
      "zagraj " <> query ->
        case resolve_query(query) do
          {:ok, url} ->
            case get_voice_channel_of_msg(message) do
              nil ->
                Api.create_message(message.channel_id, "Yyyy... Tylko gdzie? Pierwsze wejdź na jakiś kanał głosowy, a potem mnie wołaj")
              voice_channel_id ->
                Api.create_message(message.channel_id, "Okej, tylko sie szybko przygotuję i gramy")
                Api.create_message(message.channel_id, url)
                Voice.join_channel(message.guild_id, voice_channel_id)
                timeout_until_ready(message.guild_id)
                Voice.play(message.guild_id, url, :ytdl)
            end
          :error ->
            Api.create_message(message.channel_id, "Nie mogę nic znaleść")
        end
      "start" ->
        Voice.resume(message.guild_id)
        Api.create_message(message.channel_id, "No to lecimy dalej!")
      "stop" ->
        Voice.pause(message.guild_id)
        Api.create_message(message.channel_id, "Pora na chwilę odpoczynku")
      "koniec" ->
        Voice.stop(message.guild_id)
        Api.create_message(message.channel_id, "Co, czemu? Przecież nie pomyliłam żadnej nuty!")
        Process.sleep(1000)
        Api.create_message(message.channel_id, "No dobra, ale tylko raz!")
      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end

  def get_voice_channel_of_msg(msg) do
    msg.guild_id
    |> GuildCache.get!()
    |> Map.get(:voice_states)
    |> Enum.find(%{}, fn v -> v.user_id == msg.author.id end)
    |> Map.get(:channel_id)
  end

  def resolve_query(query) do
    if String.starts_with?(query, "http") do
      {:ok, query}
    else
      encoded_query =
        query
        |> String.normalize(:nfd)
        |> String.replace(~r/[^A-z\s]/u, "")
        |> URI.encode
      case HTTPoison.get "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=1&q=#{encoded_query}&type=video&key=#{@youtube_data_api_key}" do
        {:ok, response} ->
          body = Jason.decode!(response.body)
          results = Map.get(body, "items")
          case results do
            [] -> :error
            [first_result | _tail] ->
              id_map = Map.get(first_result, "id")
              video_id = Map.get(id_map, "videoId")
              {:ok, "https://www.youtube.com/watch?v=" <> video_id}
          end
        _ -> :error
      end
    end
  end
end
