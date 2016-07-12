require './app'
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

run Sinatra::Application
