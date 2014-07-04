# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' do

  # Model files
  watch(%r{^models/(.+)\.rb$})                           { |m| "spec/models/#{m[1]}_spec.rb" }
  watch('freecinc.rb')                                    { 'spec/controllers/app_controller_spec.rb' }
  watch(%r{^presenters/(.+)\.rb$})                           { |m| "spec/presenters/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})

end

# ********************************
# To run just livereload:
#   guard -g views
#
# to add a delay, pass in { grace_period: 3 }

group :views do
  guard 'livereload' do
    watch(%r{views/.+\.haml$})
    watch(%r{helpers/.+\.rb})

    #watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html))).*}) { |m| "/assets/#{m[3]}" }
    watch(%r{(public/(.+\.(css|js)))}) { |m| "/public/#{m[2]}" }
  end
end
