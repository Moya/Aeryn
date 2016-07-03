require 'sinatra'

class SignatureVerifier

  def verify_signature(payload_body, request)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload_body)
    header = request.env['HTTP_X_HUB_SIGNATURE']
    return false unless header
    return false unless Rack::Utils.secure_compare(signature, header)
  end

end
