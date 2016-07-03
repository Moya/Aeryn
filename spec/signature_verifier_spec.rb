require File.expand_path('../spec_helper', __FILE__)

describe 'SignatureVerifier' do
  let(:signature_verifier) { SignatureVerifier.new }
  let(:payload) { '{"some_data": "awesome json"}' }

  it 'returns false with a missing header' do
    result = signature_verifier.verify_signature(payload, nil)

    expect(result).to be_falsey
  end

  it 'returns false with an invalid signature' do
    result = signature_verifier.verify_signature(payload, 'some_invalid_signature')

    expect(result).to be_falsey
  end

  it 'returns true with a valid signature' do
    valid_signature = 'sha1=' + OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha1'),
      ENV['WEBHOOK_SECRET_TOKEN'],
      payload
    )

    result = signature_verifier.verify_signature(payload, valid_signature)

    expect(result).to be_truthy
  end
end
