require 'sinatra'
require './lib/web_hook_processor'

class AerynApp < Sinatra::Base
  attr_accessor :web_hook_processor

  def initialize(web_hook_processor = Sinatra::WebHookProcessor.new)
    @web_hook_processor = web_hook_processor
  end

  post ENV['WEBHOOK_ENDPOINT'] do
    request.body.rewind
    payload_body = request.body.read

    if @web_hook_processor.handle_push(payload_body, request)
    	status 200
    	body 'Processed.'
    else
    	status 400
    	body 'Error processing.'
    end
  end
end
