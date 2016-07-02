require 'json'
require 'octokit'
require 'sinatra'

class API

  def handle_push(payload_body)
    push = JSON.parse(payload_body)
    puts 'Received push.'

    return if is_ping(push)

    verify_signature(payload_body)

    return unless is_merged(push)
    username = push['pull_request']['user']['login']

    client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
    if client.organization_member?(ENV['ORG_NAME'], username)
      puts "Already a member."
    else
      team_id = ENV['CONTRIBUTOR_TEAM_ID']
      puts "Inviting #{username} to team #{team_id}."

      client.add_team_membership(team_id, username)

      pr_number = push['pull_request']['number']
      repo_name = push['pull_request']['base']['repo']['full_name']
      client.add_comment(repo_name, pr_number, ENV['INVITATION_MESSAGE'])
    end
  end

  def self.is_ping(push)
    push['zen'].nil? == false
  end

  def self.is_merged(push)
    push['action'] == 'closed' && push['pull_request']['merged'] == true
  end

  def verify_signature(payload_body)
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['WEBHOOK_SECRET_TOKEN'], payload_body)
    return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end

end
