require 'public_suffix'
require 'yaml'
require 'swot'
require "addressable/uri"
require 'iso_country_codes'
require_relative "gman/version"

class Gman

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

  class << self

    attr_writer :list

    # Normalizes and checks if a given string represents a government domain
    # Possible strings to test:
    #   ".gov"
    #   "foo.gov"
    #   "foo@bar.gov"
    #   "foo.gov.uk"
    #   "http://foo.bar.gov"
    #
    # Returns boolean true if a government domain
    def valid?(text)
      Gman.new(text).valid?
    end

    # Normalizes and checks if a given string represents a research domain
    #
    # Returns boolean true if domain is a government funded research institution
    def research?(text)
      Gman.new(text).research?
    end

    # Is the given string in the form of a valid email address?
    #
    # Returns true if email, otherwise false
    def email?(text)
      Gman.new(text).email?
    end

    # Resturns PublicSuffix::List limited to our whitelisted domains
    def list
      @list ||= load_list(list_path)
    end

    # Returns PublicSuffix::List limited to research domains
    def research_list
      @research_list ||= load_list list_path("research")
    end

    # Returns an instance of our custom public suffix list
    def load_list(list_path)
      PublicSuffix::List::parse(File.new(list_path, "r:utf-8"))
    end

    # Returns the absolute path to the domain list directory
    def list_base
      File.join(File.dirname(__FILE__), "../config/")
    end

    # Returns the absolute path to the domain list file
    def list_path(file="domains")
      File.join(list_base, "#{file}.txt")
    end
  end

  # Creates a new Gman instance
  #
  # text - the input string to check for governmentiness
  def initialize(text)
    @text = text.to_s.downcase.strip
  end

  # Parse the domain from the input string
  #
  # Can handle urls, domains, or emails
  #
  # Returns the domain string
  def domain
    @domain ||= begin
      return nil if @text.empty?

      uri = Addressable::URI.parse(@text)

      if uri.host # valid https?://* URI
        uri.host
      elsif email?
        @text.match(/@([\w\.\-]+)\Z/i)[1]
      else # url sans http://
        begin
          uri = Addressable::URI.parse("http://#{@text}")
          # properly parse http://foo edge cases
          # see https://github.com/sporkmonger/addressable/issues/145
          uri.host if uri.host =~ /\./
        rescue Addressable::URI::InvalidURIError
          nil
        end
      end
    end
  end
  alias_method :to_s, :domain

  # Checks if the input string represents a government domain
  #
  # Returns boolean true if a government domain
  def valid?
    # Ensure it's a valid domain
    return false unless PublicSuffix.valid?(domain)

    # Ensure non-edu
    return false if Swot::is_academic?(domain)

    # check using public suffix's standard logic
    rule = Gman.list.find domain
    return true if !rule.nil? && rule.allow?(domain)

    # also allow for explicit matches to domain list
    Gman.list.rules.any? { |rule| rule.value == domain }
  end

  # Checks if the input string represents a government research domain
  #
  # Returns boolean true if a government research domain
  def research?
    return false unless valid?

    # check using public suffix's standard logic
    rule = Gman.research_list.find domain
    return true if !rule.nil? && rule.allow?(domain)

    # also allow for explicit matches to domain list
    Gman.research_list.rules.any? { |rule| rule.value == domain }
  end

  # Is the input text in the form of a valid email address?
  #
  # Returns true if email, otherwise false
  def email?
    !!(@text =~ EMAIL_REGEX)
  end

  # Helper function to return the public suffix domain object
  #
  # Supports all domain strings (URLs, emails)
  #
  # Returns the domain object or nil, but no errors, never an error
  def domain_parts
    PublicSuffix.parse domain
  rescue PublicSuffix::DomainInvalid
    nil
  end

  # Returns the two character alpha county code represented by the domain
  #
  # e.g., United States = US, United Kingdom = GB
  def alpha2
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
    @country ||= IsoCountryCodes.find(alpha2)
  end

  # Console output
  def inspect
    "#<Gman domain=\"#{domain}\" valid=#{valid?}>"
  end
end
