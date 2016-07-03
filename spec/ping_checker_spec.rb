require File.expand_path('../spec_helper', __FILE__)
require 'ping_checker'
require 'rspec'

describe 'PingChecker' do
  let(:subject) { PingChecker.new }

  it 'handles a ping' do
    expect(subject.is_ping? '{"zen": "Howdy there!"}' ).to be_truthy
  end

  it 'handles non-pings' do
    expect(subject.is_ping? '{"boring_pr_data": "so boring"}' ).to be_falsey
  end
end