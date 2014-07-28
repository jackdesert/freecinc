# Copyright Jack Desert <jackdesert@gmail.com>
#
# This program scrapes blog.shopittome.com and prints to stdout the blog titles and the
# urls of the images for each blog entry

require 'pry'

class TaskdChecker
  PORT = 53589
  TIMEOUT = 5
  RECIPIENTS = ['jworky@gmail.com']
  SUCCESS = '0'

  attr_reader :server

  def initialize(server)
    @server = server
  end

  def notify_unless_up?
    notify unless up?
  end

  def up?
    output_from_nc == SUCCESS
  end

  private

  def command
    "nc -z -w#{TIMEOUT} #{server} #{PORT}; echo $?"
  end

  def output_from_nc
    output = `#{command}`
    output.strip
  end

  def email_body
    "taskd is down on port #{PORT} at at #{Time.now}"
  end

  def email_subject
    "taskd on #{server} is down"
  end

  def notify
    puts "Emailing new entry: #{@title}"
    RECIPIENTS.each do |recipient|
      mail_command = "echo '#{email_body}' | msmtp #{recipient}"
      `#{mail_command}`
    end
  end
end

prod  = TaskdChecker.new('freecinc.com')
stage = TaskdChecker.new('freecinc-staging.com')
[prod, stage].each do |server|
  server.notify_unless_up?
end


