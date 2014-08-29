# In order to insert a task into a given user's list, run this file to generate the proper output. 

# Run this file
# Append the output from this file to a user's data file and they will see it as a new task

require 'securerandom'
require 'json'

class Notice
  HIGH = 'H'
  SPACE = ' '
  INTRODUCTION = '(Note from FreeCinc.com) '

  attr_reader :message

  def initialize(arg_array)
    raise ArgumentError, 'message required' if arg_array.empty?
    @message = INTRODUCTION + arg_array.join(SPACE)
  end

  def write 
    "#{new_task_as_json}\n#{uuid}"
  end

  private
  def timestamp
    @timestamp ||= Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
  end
  
  def uuid
    SecureRandom.uuid
  end
  
  def output_hash
    { 
      description: message, 
      due: timestamp,
      entry: timestamp,
      priority: HIGH,
      project: :FreeCinc,
      status: :pending,
      uuid: uuid
    }
  end
  
  def new_task_as_json
    output_hash.to_json
  end

end

notice = Notice.new(ARGV)
puts ''
puts notice.write
