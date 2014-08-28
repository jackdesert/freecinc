require 'pry'
require 'open3'
require 'securerandom'
require 'benchmark'
require './ez_mail'

class SyncChecker
  RECIPIENTS = ['jworky@gmail.com']
  EXECUTABLE = '/usr/local/bin/task'
  SUCCESS_STRING = 'Sync successful'
  INDENT = '    '
  TIMEOUT = 5


  attr_reader :created_at, :server
  attr_accessor :stdout, :stderr, :exitstatus, :add_task_time, :sync_time, :email_time

  def initialize(server)
    @created_at = timestamp
    @server = server
    
    # stdout and stdin are strings so they can be appended to later
    @stdout = ''
    @stderr = ''

    validate_server
  end

  def notify_unless_up?
    notify unless up?
  end

  def up?
    add_task
    sync
    log(stdout_and_stderr)
    log(time_stats)
    exitstatus == 0 && stdout_and_stderr.include?(SUCCESS_STRING)
  end

  private

  def timestamp
    # This includes milliseconds
    # 2014-08-23 15:52:15.30569822
    Time.now.strftime "%Y-%m-%d %H:%M:%S.%7N"
  end

  def taskrc
    "~/.taskrc-#{server}"
  end
  
  def set_taskrc
    "TASKRC=#{taskrc}"
  end

  def logfile
    "log/sync_checker_#{server}.log"
  end

  def validate_server
    unless ['freecinc', 'freecinc-staging'].include? server
      raise ArgumentError, 'invalid TASKRC'
    end
  end

  def add_task_command
    # memoization used to ensure that the random part remains the same for a particular instance
    return @add_task_command if @add_task_command
    @add_task_command = "#{set_taskrc} #{EXECUTABLE} add 'walk the #{SecureRandom.hex}'"
  end 

  def sync_command
    # no memoization required, as no random elements exist
    "#{set_taskrc} #{EXECUTABLE} sync"
  end

  def run_command(command)
    log command
    Open3.popen3( command ) do |block_stdin, block_stdout, block_stderr, wait_thr|
      self.stdout += block_stdout.read
      self.stderr += block_stderr.read
      self.exitstatus = wait_thr.value.exitstatus
    end
  end  
 
  def add_task
    self.add_task_time = Benchmark.measure do
      run_command(add_task_command)
    end
  end

  def sync
    self.sync_time = Benchmark.measure do
      begin
        Timeout::timeout(TIMEOUT) do 
          run_command(sync_command)
        end
      rescue Timeout::Error
        self.stderr += "Sync timed out after #{TIMEOUT} seconds"
      end
    end
  end

  def stdout_and_stderr
    "#{stdout} #{stderr}"
  end

  def log(text)
    text_formatted = text.gsub(/\n+/, "\n").gsub(/^/, INDENT)
    text_with_time = "#{created_at} #{text_formatted}\n"
    puts text_formatted
    File.open(logfile, 'a') {|f| f.write(text_with_time) }
  end

  def email_body
    <<EOF
taskd failed to sync at #{created_at} on #{server}.com
commands:
#{add_task_command}
#{sync_command}
response:
#{stdout_and_stderr}
EOF
  end

  def email_subject
    "Sync Failure #{server}.com #{created_at}"
  end

  def time_stats
    <<EOF

add_task_time:
#{add_task_time}
sync_time:
#{sync_time}
email_time:
#{email_time}
EOF
  end


  def notify
    self.email_time = Benchmark.measure do
      RECIPIENTS.each do |email_recipient|
        mail = EZMail.new(email_recipient, email_subject, email_body)
        mail.deliver
      end
    end
    log("emails sent to #{RECIPIENTS}\n#{time_stats}")
  end
end

# Notice equal lengh server names for nice log formatting
prod  = SyncChecker.new('freecinc')
stage = SyncChecker.new('freecinc-staging')


[prod, stage].each do |server|
  server.notify_unless_up?
end

