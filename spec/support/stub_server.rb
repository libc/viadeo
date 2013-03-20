require 'sinatra/base'
require 'json'

class DummyStubServer < Sinatra::Base
  [:get, :post, :put, :delete].each do |verb|
    send(verb, //) do
      if request.fullpath =~ /_raise_http_(\d{3})/
        status $1
      end

      content_type :json
      {method: verb, url: request.fullpath, params: params, content_type: request.content_type}.to_json
    end
  end

  class << self
    attr_accessor :base_url
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    q = Queue.new

    Thread.fork do
      DummyStubServer.set(:port, 0)
      DummyStubServer.set(:server, %w[webrick])
      DummyStubServer.run! do |server|
        Viadeo::Client.base_url = "http://localhost:#{server.config[:Port]}/"
        q.push :go!
      end
    end

    q.pop
  end
end
