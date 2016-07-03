require File.expand_path('../spec_helper', __FILE__)

describe 'API' do
  include Rack::Test::Methods

  let(:api) { API.new(github_client) }
  let(:github_client) { double(Octokit::Client) }


  it 'does not invite for unmerged PRs' do
    result = api.handle_push({'action' => 'closed', 'pull_request' => {'merged' => false}})

    expect(result['msg']) == 'Pull request not yet merged.'
  end

  it 'does not re-invite members' do
    allow(github_client).to receive(:organization_member?).with('Organization', 'splendid_username').and_return(true)
    
    result = api.handle_push({'action' => 'closed', 
      'pull_request' => {
        'merged' => true, 
        'number' => 13,
        'user' => {'login' => 'splendid_username'}
        }})

    expect(result['msg']).to eq('Already a member.')
  end

  it 'adds team membership and sends a friendly comment' do
    allow(github_client).to receive(:organization_member?).with('Organization', 'splendid_username').and_return(false)
    allow(github_client).to receive(:add_team_membership).with('1234567', 'splendid_username')
    allow(github_client).to receive(:add_comment).with('my_repo', 13, 'Thanks!')

    result = api.handle_push({'action' => 'closed', 
      'pull_request' => {
        'merged' => true, 
        'number' => 13,
        'user' => {'login' => 'splendid_username'},
        'base' => {'repo' => {'full_name' => 'my_repo'}}
        }})

    expect(result['msg']) == 'Invitation sent.'
  end
end
