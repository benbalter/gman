require 'public_suffix'
require 'yaml'
require 'swot'
require "addressable/uri"

module Gman

  # Source: http://bit.ly/1n2X9iv
  EMAIL_REGEX = %r{
        ^
        (
          [\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+
          \.
        )
        *
        [\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+
        @
        (
          (
            (
              (
                (
                  [a-z0-9]{1}
                  [a-z0-9\-]{0,62}
                  [a-z0-9]{1}
                )
                |
                [a-z]
              )
              \.
            )+
            [a-z]{2,6}
          )
          |
          (
            \d{1,3}
            \.
          ){3}
          \d{1,3}
          (
            \:\d{1,5}
          )?
        )
        $
      }xi

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
    def valid?(text)

      domain = get_domain text
      return false unless PublicSuffix.valid?(domain)

      # Ensure non-edu
      return false if domain_parts(domain).sld && Swot::is_academic?(domain)

      # check using public suffix's standard logic
      rule = list.find domain
      return true if !rule.nil? && rule.allow?(domain)

      # also allow for explicit matches to domain list
      list.rules.any? { |rule| rule.value == domain }
    end

    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List but is limited to our whitelisted domains
    def list
      @list ||= PublicSuffix::List::parse(File.new(list_path, "r:utf-8"))
    end

    # Get the FQDN name from a URL or email address.
    #
    # Returns a string with the FQDN; nil if there's an error.
    def get_domain(text)

      return nil if text.to_s.strip.empty?

      text = text.downcase.strip
      uri = Addressable::URI.parse(text)

      if uri.host # valid https?://* URI
        uri.host
      elsif email?(text)
        text.match(/@([\w\.\-]+)\Z/i)[1]
      else # url sans http://
        begin
          uri = Addressable::URI.parse("http://#{text}")
          # properly parse http://foo edge cases
          # see https://github.com/sporkmonger/addressable/issues/145
          uri.host if uri.host =~ /\./
        rescue Addressable::URI::InvalidURIError
          nil
        end
      end
    end

    # Helper function to return the public suffix domain object
    #
    # Supports all domainy strings (URLs, emails)
    #
    # Returns the domain object or nil, but no errors, never an error
    def domain_parts(text)
      begin
        PublicSuffix.parse get_domain(text)
      rescue
        nil
      end
    end

    # Is the given string in the form of a valid email address?
    #
    # Returns true if email, otherwise false
    def email?(text)
      text =~ EMAIL_REGEX
    end

    # Returns the absolute path to the domain list
    def list_path
      @list_path ||= File.join(File.dirname(__FILE__), "domains.txt")
    end
  end
end
