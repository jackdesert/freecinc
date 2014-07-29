# Copyright Jack Desert <jackdesert@gmail.com>
#
# This program scrapes blog.shopittome.com and prints to stdout the blog titles and the
# urls of the images for each blog entry

require 'pry'

class PortChecker
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

  def email_body_with_subject
    output = <<EOF
Subject: #{email_subject}
#{email_body}
EOF
  end

  def email_body
    "taskd is down on port #{PORT} at at #{Time.now}"
  end

  def email_subject
    "taskd on #{server} is down"
  end

  def notify
    puts email_body_with_subject
    RECIPIENTS.each do |recipient|
      mail_command = "echo -e \"#{email_body_with_subject}\" | msmtp #{recipient}"
      `#{mail_command}`
    end
  end
end

prod  = PortChecker.new('freecinc.com')
stage = PortChecker.new('freecinc-staging.com')
prod.send :notify
[prod, stage].each do |server|
  server.notify_unless_up?
end


