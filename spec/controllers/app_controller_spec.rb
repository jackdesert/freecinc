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

describe '/generated_keys' do
  subject { browser.get '/generated_keys' }
  it 'returns 200' do
    subject.status.should == 200
    (subject.body.length > 2000).should be_true
  end
end

describe '/download/:filename' do

  let(:user_name) { user.name }
  let(:user) { User.new }
  let(:any_uuid) { SecureRandom.uuid }
  subject { browser.post "/download/#{user_name}.key.pem", token: user.password, uuid_for_mirakel: any_uuid  }

  it 'returns 200' do
    subject.status.should == 200
  end

end
