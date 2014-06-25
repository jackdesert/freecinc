require 'sinatra'
require 'pry'

set :port, 8854

# Bind to 0.0.0.0 even in development mode for access from VM
set :bind, '0.0.0.0'


env = ENV['RACK_ENV'] || 'development'



require 'json'

# Require all your models manually here
# require './presenters/history_presenter'

get '/' do
  html = File.read(File.join('views', 'home', 'index.html'))
end

post '/generate' do
  html = File.read(File.join('views', 'home', 'index.html'))
end


