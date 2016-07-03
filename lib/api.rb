require 'json'
require 'octokit'

class API

  attr_accessor :github_client

  def initialize(github_client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN']))
    @github_client = github_client
  end

  def handle_push(push)
    if is_merged?(push)
      pull_request = push['pull_request']
      username = pull_request['user']['login']
      
      # Should check invitation status too/instead
      if @github_client.organization_member?(ENV['ORG_NAME'], username)
        return {'msg' => 'Already a member.'}
      else
        team_id = ENV['CONTRIBUTOR_TEAM_ID']

        @github_client.add_team_membership(team_id, username)

        pr_number = pull_request['number']
        repo_name = pull_request['base']['repo']['full_name']
        @github_client.add_comment(repo_name, pr_number, ENV['INVITATION_MESSAGE'])
        return {'msg' => 'Invitation sent.'}
      end
    else
      return {'msg' => 'Pull request not yet merged.'}
    end
  end

  def is_merged?(push)
    push['action'] == 'closed' && push['pull_request'] && push['pull_request']['merged'] == true
  end
end
