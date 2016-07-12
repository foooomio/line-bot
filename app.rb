require 'sinatra'
require 'line/bot'

def bot
  @bot ||= Line::Bot::Client.new do |config|
    config.channel_id = ENV['LINE_CHANNEL_ID']
    config.channel_secret = ENV['LINE_CHANNEL_SECRET']
    config.channel_mid = ENV['LINE_CHANNEL_MID']
  end
end

post '/callback' do
  signature = request.env['HTTP_X_LINE_CHANNELSIGNATURE']
  unless bot.validate_signature(request.body.read, signature)
    error 400 do 'BAD Request' end
  end

  receive_request = Line::Bot::Receive::Request.new(request.env)

  receive_request.data.each do |message|
    p message
    case message.content
    when Line::Bot::Message::Text
      bot.send_text(
        to_mid: message.from_mid,
        text: message.content[:text] + 'じゃない',
      )
    when Line::Bot::Message::Location
      bot.send_text(
        to_mid: message.from_mid,
        text: message.location.latitude + ', ' + message.location.longitude,
      )
    end
  end

  'OK'
end
