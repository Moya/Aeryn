require 'sinatra'
require 'api'

class AerynApp < Sinatra::Base
  attr_accessor :api

  def initialize(api = API.new)
    @api = api
  end

  post ENV['WEBHOOK_ENDPOINT'] do
    request.body.rewind
    payload_body = request.body.read
    
    halt 500 unless api.handle_push(payload_body)
  end
end
