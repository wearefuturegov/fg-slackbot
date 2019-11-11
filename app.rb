require 'dotenv'
Dotenv.load
require 'sinatra'
require 'slack-ruby-client'
require 'byebug'

# This is the endpoint Slack will send event data to
post '/events' do
  # Grab the body of the request and parse it as JSON
  request_data = JSON.parse(request.body.read)
  # The request contains a `type` attribute
  # which can be one of many things, in this case,
  # we only care about `url_verification` and `event_callback` events.
  case request_data['type']
  when 'url_verification'
    # When we receive a `url_verification` event, we need to
    # return the same `challenge` value sent to us from Slack
    # to confirm our server's authenticity.
    request_data['challenge']
  when 'event_callback'
    event = request_data['event']

    # Notify when a new channel is created.
    if event['type'] == 'channel_created'
      client = create_slack_client(ENV['OAUTH_ACCESS_TOKEN'])
      channel_id = request_data['event']['channel']['id']

      channel_info = client.channels_info(channel: channel_id)
      channel_purpose = channel_info.channel.purpose.value

      client.chat_postMessage(
        as_user: 'false',
        channel: '#general',
        text: ":satellite_antenna: <!here> New channel created: <##{request_data['event']['channel']['id']}> by: <@#{request_data['event']['channel']['creator']}>\nDescription: \"_#{channel_purpose}_\""
      )

      "Posted in slack"
    else
      "Upsupported event type"
    end
  else
    "Unsupported request data type"
  end
end

get '/health_check' do
  "All good"
end

def create_slack_client(slack_api_secret)
  Slack.configure do |config|
    config.token = slack_api_secret
    fail 'Missing API token' unless config.token
  end
  Slack::Web::Client.new
end