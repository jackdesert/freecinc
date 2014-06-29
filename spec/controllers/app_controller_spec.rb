# encoding: UTF-8

# Note freecinc is required before spec_helper
# so that the root directory gets set
require_relative '../../freecinc'

require 'spec_helper'
require 'rack/test'


def browser
  Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
end

describe '/' do
  subject { browser.get '/' }
  it 'returns 200' do
    subject.status.should == 200
  end
end

describe '/generate' do
  subject { browser.get '/generate' }
  it 'returns 200' do
    subject.status.should == 200
    (subject.body.length > 2000).should be_true
  end
end

describe '/download/:filename', focus: true do

  let(:user_name) { user.name }
  let(:user) { User.new }
  subject { browser.post "/download/#{user_name}.key.pem", token: user.password }

  it 'returns 200' do
    subject.status.should == 200
    binding.pry
  end

end
