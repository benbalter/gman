class Gman < NaughtyOrNice

  # Map last part of TLD to alpha2 country code
  ALPHA2_MAP = {
    :ac     => 'sh',
    :uk     => 'gb',
    :su     => 'ru',
    :tp     => 'tl',
    :yu     => 'rs',
    :gov    => "us",
    :mil    => "us",
    :org    => "us",
    :com    => "us",
    :net    => "us",
    :edu    => "us",
    :travel => "us",
    :info   => "us"
  }

  # Returns the two character alpha county code represented by the domain
  #
  # e.g., United States = US, United Kingdom = GB
  def alpha2
    return unless domain_parts
    alpha2 = domain_parts.tld.split('.').last
    if ALPHA2_MAP[alpha2.to_sym]
      ALPHA2_MAP[alpha2.to_sym]
    else
      alpha2
    end
  end

  # Returns the ISO Country represented by the domain
  #
  # Example Usage:
  # Gman.new("foo.gov").country.name     => "United States"
  # Gman.new("foo.gov").country.currency => "USD"
  def country
    @country ||= IsoCountryCodes.find(alpha2) if alpha2
  rescue IsoCountryCodes::UnknownCodeError
    nil
  end
end
