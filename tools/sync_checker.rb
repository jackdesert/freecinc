require 'pry'
require 'open3'
require './ez_mail'

class SyncChecker
  RECIPIENTS = ['jworky@gmail.com']
  SUCCESS_STRING = 'Sync successful'
  INDENT = '    '


  attr_reader :time, :server
  attr_accessor :stdout, :stderr, :exitstatus

  def initialize(server)
    @server = server
    @time = Time.now
    validate_server
  end

  def notify_unless_up?
    notify unless up?
  end

  def up?
    sync
    exitstatus == 0 && command_output.include?(SUCCESS_STRING)
  end

  private

  def taskrc
    "~/.taskrc-#{server}"
  end

  def logfile
    "log/sync_checker_#{server}.log"
  end

  def validate_server
    unless ['freecinc', 'freecinc-staging'].include? server
      raise ArgumentError, 'invalid TASKRC'
    end
  end

  def command
    set_taskrc = "TASKRC=#{taskrc}"
    "#{set_taskrc} task add 'walk the #{SecureRandom.hex}' && #{set_taskrc} task sync"
    #"#{set_taskrc} task add 'walk the #{SecureRandom.hex}'"
  end

  def sync
    Open3.popen3( command ) do |block_stdin, block_stdout, block_stderr, wait_thr|
      self.stdout = block_stdout.read
      self.stderr = block_stderr.read
      self.exitstatus = wait_thr.value.exitstatus
    end
    log command_output
  end

  def command_output
    "#{stdout} #{stderr}"
  end

  def log(text)
    time = Time.now.utc
    text_formatted = text.gsub(/\n+/, "\n").gsub(/^/, INDENT)
    text_with_time = "#{time} #{text_formatted}\n"
    puts text_formatted
    File.open(logfile, 'a') {|f| f.write(text_with_time) }
  end

  def email_body
    "taskd failed to sync at #{Time.now}"
  end

  def email_subject
    "TASKD Failed to Sync on #{server}"
  end


  def notify
    RECIPIENTS.each do |email_recipient|
      mail = EZMail.new(email_recipient, email_subject, email_body)
      mail.deliver
      log("email sent to #{email_recipient}")
    end
  end
end

# Notice equal lengh server names for nice log formatting
prod  = SyncChecker.new('freecinc')
stage = SyncChecker.new('freecinc-staging')

[prod, stage].each do |server|
  server.notify_unless_up?
end

