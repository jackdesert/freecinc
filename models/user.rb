class User

  extend Forwardable

  DEFAULT_ORGANIZATION = 'DoersClub'

  attr_reader :name

  def initialize
    @name = generate_unique_name
    become_certified
  end

  private

  def become_certified
    @certificates = Forge.new(name, organization).generate_certificates
  end

  def_delegator :@certificates, :key,  :key
  def_delegator :@certificates, :cert, :cert
  def_delegator :@certificates, :ca,   :ca

  def organization
    DEFAULT_ORGANIZATION
  end

  def generate_unique_name
    hex = SecureRandom.hex(4)
    "user_#{hex}"
  end

end
