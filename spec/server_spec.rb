require File.expand_path('../spec_helper', __FILE__)

describe 'AerynApp' do
  include Rack::Test::Methods

  let(:app) { AerynApp.new(signature_verifier, ping_checker, api) }
  let(:signature_verifier) { double(SignatureVerifier) }
  let(:ping_checker) { double(PingChecker) }
  let(:api) { double(API) }

  it 'always responds to ping' do
    allow(signature_verifier).to receive(:verify_signature).and_return(false)
    allow(ping_checker).to receive(:is_ping?).and_return(true)

    post '/payload', '{"zen": "Howdy!"}'

    expect(last_response).to be_ok
  end

  it 'fails with invalid signature' do
    allow(signature_verifier).to receive(:verify_signature).and_return(false)
    allow(ping_checker).to receive(:is_ping?).and_return(false)

    post '/payload', '{"msg": "Imma hacker lemme in!"}'

    expect(last_response).to_not be_ok
    expect(last_response.status) == 403
  end

  it 'passes on to the api' do
    allow(signature_verifier).to receive(:verify_signature).and_return(true)
    allow(ping_checker).to receive(:is_ping?).and_return(false)
    allow(api).to receive(:handle_push).and_return ({'msg' => 'Everything is fine.'})
    
    post '/payload', '{}'

    expect(last_response).to be_ok
    expect(last_response.status) == 200
    expect(JSON.parse(last_response.body)['error']) == 'Everything is fine.'
  end

  it 'defers to the api for response code' do
    allow(signature_verifier).to receive(:verify_signature).and_return(true)
    allow(ping_checker).to receive(:is_ping?).and_return(false)
    allow(api).to receive(:handle_push).and_return({'error' => 'Something went wrong.'})
    
    post '/payload', '{}'

    expect(last_response.status) == 400
    expect(JSON.parse(last_response.body)['error']) == 'Something went wrong.'
  end
end
