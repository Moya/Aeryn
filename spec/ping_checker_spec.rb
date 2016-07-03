require File.expand_path('../spec_helper', __FILE__)

describe 'PingChecker' do
  let(:subject) { PingChecker.new }

  it 'handles a ping' do
    expect(subject.ping?('{"zen": "Howdy there!"}')).to be_truthy
  end

  it 'handles non-pings' do
    expect(subject.ping?('{"boring_pr_data": "so boring"}')).to be_falsey
  end
end
