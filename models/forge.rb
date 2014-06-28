require 'yaml'
require 'open3'

class Forge

  CONFIG_FILE = File.expand_path('../config/location.yml-EXAMPLE', File.dirname(__FILE__))

  TASKDDATA = YAML.load_file(CONFIG_FILE)['taskddata']
  INSTALL_DIR = YAML.load_file(CONFIG_FILE)['install_dir']
  PKI_DIR = YAML.load_file(CONFIG_FILE)['pki_dir']
  SINATRA_ROOT = YAML.load_file(CONFIG_FILE)['sinatra_root']

  SET_DATA_DIR = "--data #{TASKDDATA}"

  STARTS_WITH_LETTER = /\A[a-zA-Z]/
  NUMBERS_LETTERS_AND_UNDERSCORE = /\A[_a-zA-Z0-9]+\z/

  attr_reader :user_name, :user_organization

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

      OpenStruct.new( key: user_key,
                      cert: user_certificate,
                      ca: ca )
    end
  end

  private

  def in_pki_dir(&block)
    cd_to_pki_dir
    yield
  end

  def validate
    hash = { user_name: user_name,
             user_organization: user_organization }

    hash.each do |method, value|
      unless value.match(STARTS_WITH_LETTER) && value.match(NUMBERS_LETTERS_AND_UNDERSCORE)
        raise ArgumentError, "#{method} '#{value}' invalid"
      end
    end
  end


  def bash(command, tolerate_errors=false)
    stdin, stdout_and_stderr, wait_thr = Open3.popen2e(command)

    unless (wait_thr.value.success? || tolerate_errors)
      raise ArgumentError, stdout_and_stderr.read
    end

    stdin.close
    stdout_and_stderr.close
  end

  def bash_with_tolerated_errors(command)
    bash(command, true)
  end

  def copy_user_keys_to_taskddata
    bash("cp #{user_name}.* #{TASKDDATA}")
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

  def register_user
    ensure_user_organization_exists
    bash("taskd add user '#{user_organization}' '#{user_name}' #{SET_DATA_DIR}")
  end

  def ensure_user_organization_exists
    bash_with_tolerated_errors("taskd add org #{user_organization} #{SET_DATA_DIR}")
  end
end
