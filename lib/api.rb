require 'json'
require 'octokit'

class API
  attr_accessor :github_client
  attr_accessor :team_id

  def initialize(github_client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN']))
    @github_client = github_client
    @team_id = ENV['CONTRIBUTOR_TEAM_ID']
  end

  def handle_push(push)
    return { 'msg' => 'Pull request not yet merged.' } unless merged?(push)

    pull_request = push['pull_request']
    username = pull_request['user']['login']
    pr_number = pull_request['number']
    repo_name = pull_request['base']['repo']['full_name']

    return { 'msg' => 'Already a member.' } unless needs_invitation?(@team_id, username)

    invite_and_comment(@team_id, username, pr_number, repo_name)

    { 'msg' => 'Invitation sent.' }
  end

  def merged?(push)
    push['action'] == 'closed' && push['pull_request'] && push['pull_request']['merged'] == true
  end

  def needs_invitation?(team_id, username)
    # This raises if the user has not been invited yet, as the happy
    # path is 'user invitation is pending' or 'user has accepted'.
    @github_client.team_membership(team_id, username)
    return false
  rescue Octokit::NotFound
    return true
  end

  def invite_and_comment(team_id, username, pr_number, repo_name)
    @github_client.add_team_membership(team_id, username)
    @github_client.add_comment(repo_name, pr_number, ENV['INVITATION_MESSAGE'])
  end
end
