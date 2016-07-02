require File.expand_path('../spec_helper', __FILE__)
require 'web_hook_processor'
require 'rspec'

describe 'WebHookProcessor' do
  include Rack::Test::Methods

  let(:subject) { Sinatra::WebHookProcessor.new({
    signature_verifier: double(),
    ping_checker: double(),
    merge_checker: double(),
    github_client: double()
  }) }

  it 'verifies signature' do
    allow(subject.signature_verifier).to receive(:verify_signature).and_return(false)

    success = subject.handle_push('{}', nil)

    expect(success).to be_falsey
  end

  describe 'verified signature' do
    before do
      allow(subject.signature_verifier).to receive(:verify_signature).and_return(true)
    end

    it 'succeeds on ping' do
      allow(subject.ping_checker).to receive(:is_ping?).and_return(true)

      success = subject.handle_push('{}', nil)

      expect(success).to be_truthy
    end

    describe 'not a ping' do
      before do
        allow(subject.ping_checker).to receive(:is_ping?).and_return(false)
      end

      it 'bails unless merged' do
        allow(subject.merge_checker).to receive(:is_merged?).and_return(false)

        success = subject.handle_push('{}', nil)

        expect(success).to be_truthy
      end

      it 'checks for existing membership' do
        allow(subject.merge_checker).to receive(:is_merged?).and_return(true)
        allow(subject.github_client).to receive(:organization_member?).with('Organization', 'splendid_username').and_return(true)

        success = subject.handle_push('{"pull_request": {"user": {"login": "splendid_username"}}}', nil)

        expect(success).to be_truthy
      end

      it 'adds team membership and sends a friendly comment' do
        allow(subject.merge_checker).to receive(:is_merged?).and_return(true)
        allow(subject.github_client).to receive(:organization_member?).with('Organization', 'splendid_username').and_return(false)
        allow(subject.github_client).to receive(:add_team_membership).with('1234567', 'splendid_username').and_return(false)
        allow(subject.github_client).to receive(:add_comment).with('my_repo', 13, 'Thanks!').and_return(false)

        success = subject.handle_push('{"pull_request": {"user": {"login": "splendid_username"}, "number": 13, "base": {"repo": {"full_name": "my_repo"}}}}', nil)

        expect(success).to be_truthy
      end
    end
  end
end
