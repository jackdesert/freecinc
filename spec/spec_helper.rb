ENV['RACK_ENV'] = 'test'

require 'sinatra'

# Set Sequel::Model to return nil if save fails, as opposed to raising an exception
#Sequel::Model.raise_on_save_failure = false

require 'pry'
require 'rspec'
require 'rr'

# DB must be defined before models are required

require_relative '../models/forge'
require_relative '../models/user'
require_relative '../helpers/view_helper'

RSpec.configure do |config|
  config.mock_with :rr

  # Allow running one test at a time
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

end

