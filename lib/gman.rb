require 'public_suffix'
require 'yaml'

module Gman

  VERSION='0.0.1'

  class << self

    # Normalizes and checks if a given string represents a governemnt domain
    # Possible strings to test:
    #   ".gov"
    #   "foo.gov"
    #   "foo@bar.gov"
    #   "foo.gov.uk"
    #   "http://foo.bar.gov"
    #
    # Returns boolean true if a government domain
    def is_government?(text)
      return false if text.nil?
      text.strip!

      begin
        domain = get_domain(text)
        return false if domain.nil?

        match_government_domain?(domain)

      rescue PublicSuffix::DomainInvalid => di
        false

      rescue PublicSuffix::DomainNotAllowed => dna
        false
      end

    end

    # Checks the TLD (e.g., .gov) or TLD+SLD (e.g., .gov.uk)
    # Against list of known government domains
    def match_government_domain?(domain)
      domains.include?(domain.tld) || domains.include?("#{domain.tld}.#{domain.sld}")
    end

    # Parses YML domain list into an array
    # TODO: Cache this
    #
    # Returns an array of TLD and TLD+SLD known government domains
    def domains
       YAML.load_file File.expand_path("../domains.yml", __FILE__)
    end

    # Get the FQDN name from a URL or email address.
    #
    # Returns a string with the FQDN; nil if there's an error.
    # Source: https://github.com/leereilly/swot/blob/master/lib/swot.rb#L190
    def get_domain(text)
      PublicSuffix.parse text.downcase.match(domain_regex).captures.first
    rescue
      return nil
    end

    private

    # Source: https://github.com/leereilly/swot/blob/master/lib/swot.rb#L202
    def domain_regex
      /([^@\/:]+)[:\d]*$/
    end
  end
end
