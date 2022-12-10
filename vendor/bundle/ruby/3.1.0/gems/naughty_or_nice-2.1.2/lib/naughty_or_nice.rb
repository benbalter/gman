# frozen_string_literal: true

require 'public_suffix'
require 'addressable/uri'
require_relative './naughty_or_nice/version'

# Primary module to be mixed into the child class
module NaughtyOrNice
  # Source: http://bit.ly/1n2X9iv
  EMAIL_REGEX = %r{
        ^
        (
          [\w!\#$%&'*+\-/=?\^`\{|\}~]+
          \.
        )
        *
        [\w!\#$%&'*+\-/=?\^`\{|\}~]+
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
            :\d{1,5}
          )?
        )
        $
      }xi.freeze

  # Ruby idiom that allows `include` to create class methods
  module ClassMethods
    def valid?(text)
      new(text).valid?
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(domain)
    if domain.is_a?(PublicSuffix::Domain)
      @domain = domain
      @text   = domain.to_s
    else
      @text = domain.to_s.downcase.strip
    end
  end

  # Return the public suffix domain object
  #
  # Supports all domain strings (URLs, emails)
  #
  # Returns the domain object or nil, but no errors, never an error
  def domain
    return @domain if defined? @domain

    @domain = begin
      PublicSuffix.parse(normalized_domain, default_rule: nil)
    rescue PublicSuffix::DomainInvalid, PublicSuffix::DomainNotAllowed
      nil
    end
  end

  # Checks if the input string represents a valid domain
  #
  # Returns boolean true if a valid domain, otherwise false
  def valid?
    !domain.nil?
  end

  # Is the input text in the form of a valid email address?
  #
  # Returns true if email, otherwise false
  def email?
    !(@text =~ EMAIL_REGEX).nil?
  end

  # Return the parsed domain as a string
  def to_s
    @to_s ||= domain.to_s if domain
  end

  def inspect
    "#<#{self.class} domain=\"#{domain}\" valid=#{valid?}>"
  end

  private

  # Parse the domain from the input string
  #
  # Can handle urls, domains, or emails
  #
  # Returns the domain string
  def normalized_domain
    if @text.empty?
      nil
    elsif parsed_domain
      parsed_domain.host
    end
  end

  def parsed_domain
    @parsed_domain ||= begin
      text = @text.dup
      text.prepend('http://') unless %r{\Ahttps?://}.match?(text)
      uri = Addressable::URI.parse(text)
      # properly parse http://foo edge cases
      # see https://github.com/sporkmonger/addressable/issues/145
      uri if uri.host.include?('.')
    end
  rescue Addressable::URI::InvalidURIError
    nil
  end
end
