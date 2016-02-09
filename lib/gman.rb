require 'naughty_or_nice'
require 'swot'
require 'iso_country_codes'
require 'csv'
require_relative 'gman/version'
require_relative 'gman/country_codes'
require_relative 'gman/locality'
require_relative 'gman/identifier'

class Gman
  include NaughtyOrNice

  class << self
    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List
    # but is limited to our whitelisted domains
    def list
      @list ||= PublicSuffix::List.parse(list_contents)
    end

    def config_path
      File.expand_path '../config', File.dirname(__FILE__)
    end

    # Returns the absolute path to the domain list
    def list_path
      if ENV['GMAN_STUB_DOMAINS']
        File.expand_path '../test/fixtures/domains.txt', File.dirname(__FILE__)
      else
        File.expand_path 'domains.txt', config_path
      end
    end

    def list_contents
      @list_contents ||= File.new(list_path, 'r:utf-8').read
    end
  end

  # Checks if the input string represents a government domain
  #
  # Returns boolean true if a government domain
  def valid?
    @valid ||= begin
      return false unless valid_domain?
      return false if academic?
      locality? || public_suffix_valid?
    end
  end

  private

  def valid_domain?
    domain && domain.valid? && !academic?
  end

  def academic?
    domain && Swot.is_academic?(domain)
  end

  # domain is on the domain list and
  # domain is not explicitly blacklisted and
  # domain matches a standard public suffix list rule
  def public_suffix_valid?
    rule = Gman.list.find(to_s)
    !rule.nil? && rule.type != :exception && rule.allow?(".#{domain}")
  end
end
