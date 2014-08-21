require 'pry'
require 'mail'

config = YAML::load_file(File.join(__dir__, 'config.yml'))

recipients = config['recipients']
user_name = config['user_name']
password = config['password']
smtp_address = config['smtp_address']


Mail.defaults do
  delivery_method :smtp, {
                            :address              => smtp_address,
                            :port                 => 587,
                            :user_name            => user_name,
                            :password             => password,
                            :authentication       => :plain,
                            :enable_starttls_auto => true
                          }
end



class EZMail

  def initialize(to_arg, subject_arg, body_arg)
    @message  = Mail.new do
                  from     Mail.delivery_method.settings[:user_name]
                  to       to_arg
                  subject  subject_arg
                  body     body_arg
                end
  end

  def deliver
    @message.deliver
  end

end

