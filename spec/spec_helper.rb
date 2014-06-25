ENV['RACK_ENV'] = 'test'

require 'sinatra'
require 'sequel'

# Set Sequel::Model to return nil if save fails, as opposed to raising an exception
#Sequel::Model.raise_on_save_failure = false

require 'pry'
require 'rspec'
require 'rr'
require 'time-warp'

# DB must be defined before models are required
DB = Sequel.sqlite
# DB migrations must happen before models are loaded
# in order for the accessors to be automagically added
# (one for each database column)
Dir["#{File.dirname(__FILE__)}/../db/migrations/*.rb"].each { |f| require(f) }

require_relative '../models/util'
require_relative '../models/verb'
require_relative '../models/human'
require_relative '../models/note'
require_relative '../models/thing'
require_relative '../models/occurrence'
require_relative '../models/verbs/action_verb'
require_relative '../models/verbs/create_verb'
require_relative '../models/verbs/create_verb_with_default'
require_relative '../models/verbs/delete_verb'
require_relative '../models/verbs/menu_verb'
require_relative '../models/verbs/last_verb'
require_relative '../models/verbs/list_verb'
require_relative '../models/verbs/nonsense_verb'
require_relative '../models/verbs/note_verb'
require_relative '../models/verbs/rename_verb'
require_relative '../models/verbs/today_verb'
require_relative '../models/verbs/update_default_verb'
require_relative '../models/verbs/yesterday_verb'
require_relative '../presenters/history_presenter'
require_relative './support/helper_methods'

RSpec.configure do |config|
  config.mock_with :rr

  # Allow running one test at a time
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

end

