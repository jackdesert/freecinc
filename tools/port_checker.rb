require 'pry'

class PortChecker
  PORT = 53589
  TIMEOUT = 5
  RECIPIENTS = ['jworky@gmail.com']
  SUCCESS = '0'
  TEMP_FILENAME = '.tempmail'
  LOG = 'log/port_checker.log'

  attr_reader :server, :time

  def initialize(server)
    @server = server
    @time = Time.now
  end

  def notify_unless_up?
    notify unless up?
  end

  def up?
    true_or_false = (output_from_nc_command == SUCCESS)
    log("#{time} #{server} #{true_or_false ? 'up' : 'down'}")
    true_or_false
  end

  private

  def log(text)
    puts text
    text_with_return = "#{text}\n"
    File.open(LOG, 'a') {|f| f.write(text_with_return) }
  end

  def nc_command
    # Example usage of nc 
    # `nc -z -w5 freecinc.com 53589; echo $?`
    "nc -z -w#{TIMEOUT} #{server} #{PORT}; echo $?"
  end

  def output_from_nc_command
    output = `#{nc_command}`
    output.strip
  end

  def email_body_with_subject
    # Two line feeds are requierd in order for body to be picked up through cat
    "Subject: #{email_subject}\n\n#{email_body}"
  end

  def email_body
    "taskd is down on port #{PORT} at #{Time.now}"
  end

  def email_subject
    "TASKD Down on #{server}"
  end

  def write_to_temp_file(text)
    File.open(TEMP_FILENAME, 'w') {|f| f.write(text) }
  end

  def clear_temp_file
    write_to_temp_file('')
  end

  def notify
    # For some reason GMAIL delivers email with no subject unless you 
    #  first save it to a file and then 'cat' it. (Echo has problems)
    write_to_temp_file(email_body_with_subject)
    RECIPIENTS.each do |recipient|
      mail_command = "cat #{TEMP_FILENAME} | msmtp #{recipient}"
      bash_output = `#{mail_command}`
      puts "ERROR SENDING MAIL: #{bash_output}" unless bash_output.empty?
      log("email to #{recipient}")
      log(indent(email_body_with_subject))
    end
    clear_temp_file
  end

  def indent(text)
    space = '  '
    text.gsub(/^/, space)
  end
end

# Notice equal lengh server names for nice log formatting
prod  = PortChecker.new('freecinc.com        ')
stage = PortChecker.new('freecinc-staging.com')

[prod, stage].each do |server|
  server.notify_unless_up?
end

