require 'sinatra'

class SignatureVerifier
  def verify_signature(payload_body, header)
    return false unless header

    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha1'),
      ENV['WEBHOOK_SECRET_TOKEN'],
      payload_body
    )
    Rack::Utils.secure_compare(signature, header)
  end
end
