class Doer

  DEFAULT_ORGANIZATION = 'Doers Club'

  attr_reader :name
  def initialize
    @name = generate_name
  end

  def generate_keys
    @key, @certificate = CertificateAuthority.certify(name, organization)
  end

  def certificate_authority
    Generator::CERTIFICATE_AUTHORITY
  end

  def organization
    DEFAULT_ORGANIZATION
  end

end

