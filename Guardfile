# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' do

  # Model files
  watch(%r{^models/(.+)\.rb$})                           { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^presenters/(.+)\.rb$})                           { |m| "spec/presenters/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})

end

