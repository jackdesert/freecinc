require 'sinatra'
require 'pry'

set :port, 9952

# Bind to 0.0.0.0 even in development mode for access from VM
set :bind, '0.0.0.0'


env = ENV['RACK_ENV'] || 'development'



require 'json'
require './helpers/view_helper'
# Require all your models manually here
# require './presenters/history_presenter'

class Sinatra::Application
  include ViewHelper
end

get '/' do
  haml :index
end

get '/generate' do
  haml :generate
end


