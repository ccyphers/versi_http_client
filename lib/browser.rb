require 'httpclient'

module VersiHTTPClient
  module Browser
    @agent = HTTPClient.new
    class << self
      attr_accessor :agent
    end
  end
end

#puts VersiHTTPClient::Browser.agent
