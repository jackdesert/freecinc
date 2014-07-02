require 'yaml'
require 'open3'

class Forge

  CONFIG_FILE = File.expand_path('../config/location.yml-EXAMPLE', File.dirname(__FILE__))

  TASKDDATA = YAML.load_file(CONFIG_FILE)['taskddata']
  INSTALL_DIR = YAML.load_file(CONFIG_FILE)['install_dir']
  PKI_DIR = YAML.load_file(CONFIG_FILE)['pki_dir']
  SINATRA_ROOT = YAML.load_file(CONFIG_FILE)['sinatra_root']
  SALT = YAML.load_file(CONFIG_FILE)['salt']

  SET_DATA_DIR = "--data #{TASKDDATA}"

  STARTS_WITH_LETTER = /\A[a-zA-Z]/
  NUMBERS_LETTERS_AND_UNDERSCORE = /\A[_a-zA-Z0-9]+\z/
  UUID = /[0-9a-f\-]{36}/

  attr_reader :user_name, :uid

  def initialize(a,b)
    raise ArgumentError, 'Instantiate a subclass of this'
  end

  def generate_password_from_user_name
    raise ArgumentError, "salt must have non-zero length" unless SALT.length > 1
    raise ArgumentError, "salt must be a string" unless SALT.is_a?(String)

    Digest::SHA1.hexdigest(user_name + SALT)
  end

  private

  def in_pki_dir(&block)
    cd_to_pki_dir
    yield
  end


  def all_certificates
    OpenStruct.new( key: user_key,
                    cert: user_certificate,
                    ca: ca,
                    uid: uid)
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


end




class OriginalForge < Forge

  attr_reader :user_organization

  def initialize(user_name, user_organization)
    @user_name = user_name
    @user_organization = user_organization
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
    hash = { user_name: user_name,
      user_organization: user_organization }

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
    uid_match = bash_response.match(UUID)
    @uid = uid_match.values_at(0).first
    raise ArgumentError, 'uuid must by 36 characters' unless uid.length == 36
  end

  def ensure_user_organization_exists
    bash_with_tolerated_errors("taskd add org #{user_organization} #{SET_DATA_DIR}")
  end

end




class CopyForge < Forge

  attr_reader :password

  def initialize(user_name, password)
    @user_name = user_name
    @password = password
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
