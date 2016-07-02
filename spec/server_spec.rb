require File.expand_path('../spec_helper', __FILE__)
require 'server'
require 'web_hook_processor'
require 'rspec'
require 'rack/test'

describe 'AerynApp' do
  include Rack::Test::Methods

  let(:app) { AerynApp.new(api) }
  let(:api) { double(Sinatra::WebHookProcessor) }

  it 'verifies payload' do
  	expect(api).to receive(:handle_push) do 
      nil
    end

  	post '/payload'

    expect(last_response).to_not be_ok
  end

  it 'passes payload through' do
    expect(api).to receive(:handle_push).and_return('Proccessed.')

    post '/payload', 'payload'

    expect(last_response).to be_ok
    expect(last_response.body) == 'Proccessed.'
  end
end
