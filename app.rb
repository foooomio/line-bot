require 'sinatra'
require 'line/bot'
require 'net/http'
require 'uri'

module Line
  module Bot
    class HTTPClient
      def http(uri)
        proxy = URI(ENV['FIXIE_URL'])
        http = Net::HTTP.new(uri.host, uri.port, proxy.host, proxy.port, proxy.user, proxy.password)
        if uri.scheme == "https"
          http.use_ssl = true
        end
        http
      end
    end
  end
end

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
    case message.content
    when Line::Bot::Message::Text
      p message
      bot.send_text(
        to_mid: message.from_mid,
        text: message.content[:text] + 'じゃない',
      )
    end
  end

  'OK'
end
