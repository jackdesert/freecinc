class User

  extend Forwardable

  attr_reader :name, :password

  def initialize
    @name = generate_unique_name
    become_certified
  end

  def organization
    Forge::DEFAULT_ORGANIZATION
  end

  private

  def become_certified
    forge = OriginalForge.new(name)
    @certificates = forge.generate_certificates
    @password = forge.generate_password_from_user_name
  end

  def_delegator :@certificates, :key,  :key
  def_delegator :@certificates, :cert, :cert
  def_delegator :@certificates, :ca,   :ca
  def_delegator :@certificates, :uuid,  :uuid
  def_delegator :@certificates, :mirakel_config,  :mirakel_config

  def generate_unique_name
    hex = SecureRandom.hex(4)
    "freecinc_#{hex}"
  end

end

