require 'json'
require 'octokit'
require 'sinatra'
require_relative 'ping_checker'
require_relative 'signature_verifier'
require_relative 'merge_checker'

use Rack::Logger

module Sinatra
  helpers do

    def logger
      request.logger
    end

    class WebHookProcessor

      attr_accessor :signature_verifier
      attr_accessor :ping_checker
      attr_accessor :merge_checker
      attr_accessor :github_client

      def initialize(args = {})
        @signature_verifier = args[:signature_verifier] || SignatureVerifier.new
        @ping_checker = args[:ping_checker] || PingChecker.new
        @merge_checker = args[:merge_checker] || MergeChecker.new
        @github_client = args[:github_client] || Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
      end

      def handle_push(payload_body, request)
        push = JSON.parse(payload_body)
        puts 'Received push.'

        return nil unless @signature_verifier.verify_signature(payload_body, request)

        return true if @ping_checker.is_ping?(push)

        return true unless @merge_checker.is_merged?(push)

        username = push['pull_request']['user']['login']
        
        if @github_client.organization_member?(ENV['ORG_NAME'], username)
          puts "Already a member."
          return true
        else
          team_id = ENV['CONTRIBUTOR_TEAM_ID']
          puts "Inviting #{username} to team #{team_id}."

          @github_client.add_team_membership(team_id, username)

          pr_number = push['pull_request']['number']
          repo_name = push['pull_request']['base']['repo']['full_name']
          @github_client.add_comment(repo_name, pr_number, ENV['INVITATION_MESSAGE'])
          return true
        end
      end
    end
  end
end
