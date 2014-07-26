require 'yaml'
require 'open3'

class Forge

  CONFIG_FILE = File.expand_path('../config/location.yml', File.dirname(__FILE__))

  TASKDDATA = YAML.load_file(CONFIG_FILE)['taskddata']
  INSTALL_DIR = YAML.load_file(CONFIG_FILE)['install_dir']
  PKI_DIR = YAML.load_file(CONFIG_FILE)['pki_dir']
  SINATRA_ROOT = YAML.load_file(CONFIG_FILE)['sinatra_root']
  SALT = YAML.load_file(CONFIG_FILE)['salt']

  DEFAULT_ORGANIZATION  = 'FreeCinc'
  SERVER                = 'freecinc.com:53589'

  SET_DATA_DIR = "--data #{TASKDDATA}"

  STARTS_WITH_LETTER = /\A[a-zA-Z]/
  NUMBERS_LETTERS_AND_UNDERSCORE = /\A[_a-zA-Z0-9]+\z/
  UUID = /[0-9a-f\-]{36}/


  attr_reader :user_name, :uuid

  def initialize(a,b)
    raise ArgumentError, 'Instantiate a subclass of this'
  end

  def generate_password_from_user_name
    raise ArgumentError, "salt must have non-zero length" unless SALT.length > 1
    raise ArgumentError, "salt must be a string" unless SALT.is_a?(String)

    Digest::SHA1.hexdigest(user_name + SALT)
  end

  private

  def user_organization
    DEFAULT_ORGANIZATION
  end

  def in_pki_dir(&block)
    cd_to_pki_dir
    yield
  end


  def all_certificates
    OpenStruct.new( key: user_key,
                    cert: user_certificate,
                    ca: ca,
                    uuid: uuid,
                    mirakel_config: mirakel_config)
  end

  def user_key
    File.read("#{user_name}.key.pem")
  end

  def ca
    File.read('ca.cert.pem')
  end

  def user_certificate
    File.read("#{user_name}.cert.pem")
  end

  def cd_to_pki_dir
    Dir.chdir(PKI_DIR)
  end

  def mirakel_config
    return <<EOF
username: #{user_name}
org: #{user_organization}
user key: #{uuid}
server: #{SERVER}
client.cert:
#{user_certificate}
Client.key:
#{user_key}
ca.cert:
#{ca}
EOF
  end


end




class OriginalForge < Forge

  def initialize(user_name)
    @user_name = user_name
    validate
  end

  def generate_certificates
    register_user

    in_pki_dir do

      bash("./generate.client #{user_name}")

      copy_user_keys_to_taskddata
      all_certificates
    end
  end

  private

  def validate
    hash = { user_name: user_name }

    hash.each do |method, value|
      unless value.match(STARTS_WITH_LETTER) && value.match(NUMBERS_LETTERS_AND_UNDERSCORE)
        raise ArgumentError, "#{method} '#{value}' invalid"
      end
    end
  end

  def password
    generate_password_from_user_name
  end

  private

  def bash(command, tolerate_errors=false)
    stdin, stdout_and_stderr, wait_thr = Open3.popen2e(command)
    output = stdout_and_stderr.read

    unless (wait_thr.value.success? || tolerate_errors)
      raise ArgumentError, stdout_and_stderr.read
    end

    stdin.close
    stdout_and_stderr.close
    output
  end

  def bash_with_tolerated_errors(command)
    bash(command, true)
  end

  def copy_user_keys_to_taskddata
    bash("cp #{user_name}.* #{TASKDDATA}")
  end

  def register_user
    ensure_user_organization_exists
    bash_response = bash("taskd add user '#{user_organization}' '#{user_name}' #{SET_DATA_DIR}")
    uuid_match = bash_response.match(UUID)
    @uuid = uuid_match.values_at(0).first
    raise ArgumentError, 'uuid must have length 36' unless uuid.length == 36
  end

  def ensure_user_organization_exists
    bash_with_tolerated_errors("taskd add org #{user_organization} #{SET_DATA_DIR}")
  end

end




class CopyForge < Forge

  attr_reader :password

  def initialize(user_name, password, uuid_for_mirakel)
    @user_name = user_name
    @password = password
    @uuid = uuid_for_mirakel
    validate
  end

  def read_user_certificates
    return nil unless authenticated?
    in_pki_dir do
      all_certificates
    end
  end

  private

  def validate
    attrs = { user_name: user_name, password: password }

    attrs.each do |key, value|
      raise ArgumentError, "#{key} must be a string" unless value.is_a?(String)
      raise ArgumentError, "#{key} must have non-zero length" unless value.length > 0
    end

    raise ArgumentError, 'uuid must have length 36' unless uuid.length == 36
  end

  def authenticated?
    return false if user_name.to_s.length < 2
    return false if password.to_s.length < 2
    answer = (generate_password_from_user_name == password)
    # This is to guard against the deletion of one of the '==' above
    raise ArgumentError, 'output must be a boolean' unless (answer.is_a?(TrueClass) || answer.is_a?(FalseClass))
    answer
  end

end
