require 'sinatra'
require 'pry'
require 'yaml'
require 'haml'

set :port, 9952

# Bind to 0.0.0.0 even in development mode for access from VM
set :bind, '0.0.0.0'

# Set :root explicitly, so that is is not generated dynamically.
# The problem with dynamic generation is that Forge.generate_certificates
# calls Dir.chdir, and then sinatra doesn't know where to look for
# views and stylesheets
set :root, settings.root


env = ENV['RACK_ENV'] || 'development'



require 'json'
require './helpers/view_helper'


class Sinatra::Application
  include ViewHelper
end

# Require all your models manually here
 require './models/user'
 require './models/forge'




get '/' do
  haml :index
end

get '/generate' do
  locals = {user: User.new}
  haml :generate, locals: locals
end

post '/download/:filename' do |filename|
  content_type 'application/octet-stream'

  user_name, method_name, pem = *filename.split('.')

  raise ArgumentError, "Unknown file '#{filename}'" unless ['key', 'cert', 'ca'].include? method_name
  copy_forge = CopyForge.new(user_name, params[:token])
  copy_forge.read_user_certificates.send(method_name)
end


