require 'spec_helper'
include ViewHelper

describe ViewHelper do
  describe 'fake_uuid' do
    it 'is 36 characters long' do
      fake_uuid.length.should == 36
    end
  end
end
