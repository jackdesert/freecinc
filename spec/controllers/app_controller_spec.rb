# encoding: UTF-8

require 'spec_helper'
require 'rack/test'
require_relative '../../daily_lager'

def sample_params
  {
    "AccountSid"=>"ACadd1d93921579bcdadb4d3d1e9aa9af3",
    "MessageSid"=>"SM00799c7b44c66c116d07622cb96887a6",
    "Body"=>"Hi6",
    "ToZip"=>"83647",
    "ToCity"=>"MT HOME",
    "FromState"=>"ID",
    "ToState"=>"ID",
    "SmsSid"=>"SM00799c7b44c66c116d07622cb96887a6",
    "To"=>"+12086960499",
    "ToCountry"=>"US",
    "FromCountry"=>"US",
    "SmsMessageSid"=>"SM00799c7b44c66c116d07622cb96887a6",
    "ApiVersion"=>"2010-04-01",
    "FromCity"=>"GLENNS FERRY",
    "SmsStatus"=>"received",
    "NumMedia"=>"0",
    "From"=>"+12083666059",
    "FromZip"=>"83633"
  }
end

def rogue_params
  {
    # Note that we are not guarding against the case where Twilio
    # does not provide a 'From' field
    "From"=>"+12223334444",
    'blither' => 'blather'
  }
end

def browser
  Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
end

describe '/messages' do
  context 'using sample params' do
    subject { browser.post '/messages', sample_params }
    it 'returns 200' do
      subject.status.should == 200
    end

    it 'makes a call to Verb#responder' do
      mock.proxy.any_instance_of(NonsenseVerb).response.returns('something')
      subject
    end

    context 'when the message is 160 characters' do
      it 'returns the whole message' do
        dummy_output = 'y' * 160
        mock.proxy.any_instance_of(NonsenseVerb).response.returns(dummy_output)
        subject.body.should == dummy_output
      end
    end

    context 'when the message is more than 160 characters' do
      it "returns 154 characters and the word 'snip'" do
        dummy_output = 'h' * 161
        mock.proxy.any_instance_of(NonsenseVerb).response.returns(dummy_output)
        subject.body.should == 'h' * 154 + '[snip]'
      end
    end

    context 'when the user does not exist' do
      before do
        DB[:humans].delete
      end

      it 'creates the user' do
        expect{
          subject
        }.to change{ Human.count }.by(1)
      end
    end

    context 'when the user exists' do
      it 'looks up the user and uses it' do
      end
    end
  end

  context 'using rogue params' do
    subject { browser.post '/messages', rogue_params }

    it 'returns 200' do
      subject.status.should == 200
    end

    it 'returns an error' do
      subject.body.should == "Oops. We've encountered an error :("
    end
  end
end

