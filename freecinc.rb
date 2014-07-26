require 'sinatra'
require 'sinatra/contrib'
require 'pry'
require 'yaml'
require 'haml'

# Note if you start via rackup this will be ignored
set :port, 9952

# Bind to 0.0.0.0 even in development mode for access from VM
set :bind, '0.0.0.0'

# Set :root explicitly, so that is is not generated dynamically.
# The problem with dynamic generation is that Forge.generate_certificates
# calls Dir.chdir, and then sinatra doesn't know where to look for
# views and stylesheets
set :root, settings.root

unless [:development, :production, :test].include? settings.environment
  # :development is default if nothing specified for RACK_ENV on command line
  raise ArgumentError, 'Unsupported environment'
end

require 'json'
require './helpers/view_helper'

class FreeCinc < Sinatra::Base
  configure :production, :development do
    enable :logging
  end
end

# include ViewHelper here so that it is both accessible in view
# and accessible in this file
include ViewHelper


# Require all your models manually here
 require './models/user'
 require './models/forge'


# /
get root_path do
  ensure_correct_environment
  haml :index
end

# /generated_keys
get generate_path do
  locals = {user: User.new}
  haml :generate, locals: locals
end

# /about
get about_path do
  haml :about
end

# /terms
get terms_path do
  haml :terms
end

post '/download/:filename' do |filename|
  content_type 'application/octet-stream'

  user_name, method_name, pem = *filename.split('.')

  raise ArgumentError, "Unknown file '#{filename}'" unless ['key', 'cert', 'ca'].include? method_name
  copy_forge = CopyForge.new(user_name, params[:token], params[:uuid_for_mirakel])
  copy_forge.read_user_certificates.send(method_name)
end


private
def ensure_correct_environment
  # Make sure RACK_ENV has been set to production if you are serving freecinc.com proper,
  # since that's the only way Sinatra knows to hide its stack traces
  if production? && !settings.production?
    raise ArgumentError, "Environment mismatch. If you are serving up freecinc.com proper, set RACK_ENV=production before starting server"
  end
end

