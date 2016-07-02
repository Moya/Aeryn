require 'sinatra'

class SignatureVerifier

  def verify_signature(payload_body, request)
    # TODO: Handle this better, add logging, see if we can halt Sinatra request from within this method.
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload_body)
    header = request.env['HTTP_X_HUB_SIGNATURE']
    return false unless header
    return false unless Rack::Utils.secure_compare(signature, header)
  end

end
