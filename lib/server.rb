require 'sinatra'
require './lib/web_hook_processor'

class AerynApp < Sinatra::Base
  attr_accessor :api

  def initialize(api = Sinatra::WebHookProcessor.new)
    @api = api
  end

  post ENV['WEBHOOK_ENDPOINT'] do
    request.body.rewind
    payload_body = request.body.read

    if api.handle_push(payload_body, request)
    	status 200
    	body 'Processed.'
    else
    	status 400
    	body 'Error processing.'
    end
  end
end
