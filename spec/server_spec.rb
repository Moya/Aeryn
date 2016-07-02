require File.expand_path('../spec_helper', __FILE__)
require 'server'
require 'api'
require 'rspec'
require 'rack/test'

describe 'AerynApp' do
  include Rack::Test::Methods

  let(:app) { AerynApp.new(api) }
  let(:api) { double(API) }

  it 'verifies payload' do
  	expect(api).to receive(:handle_push).with("") do 
      nil
    end

  	post '/payload'

    expect(last_response).to_not be_ok
  end

  it 'passes payload through' do
    expect(api).to receive(:handle_push).with('payload').and_return('Proccessed.')

    post '/payload', 'payload'

    expect(last_response).to be_ok
  end
end
