require 'sinatra'
require 'json'
require 'octokit'

class AerynApp < Sinatra::Base
  get '/' do
    "Hello there!"
  end

  post ENV['WEBHOOK_ENDPOINT'] do
    request.body.rewind
    payload_body = request.body.read
    push = JSON.parse(payload_body)
    puts payload_body

    return if is_ping(push)

    verify_signature(payload_body)

    return unless is_merged(push)
    username = push['pull_request']['user']['login']

    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    if client.organization_member?(ENV['ORG_NAME'], username)
      puts "Already a member."
    else
      puts "Inviting #{username} to team."

      add_team_membership(ENV['CONTRIBUTOR_TEAM_ID'], username)

      pr_number = push['pull_request']['number']
      repo_name = push['pull_request']['base']['repo']['full_name']
      add_comment(repo_name, pr_number, ENV['INVITATION_MESSAGE'])
    end

  end

  def is_ping(push)
    push['zen'].nil? == false
  end

  def is_merged(push)
    push['action'] == 'closed' && push['pull_request']['merged'] == true
  end

  def verify_signature(payload_body)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload_body)
    return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end

end
