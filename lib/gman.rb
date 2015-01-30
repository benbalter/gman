require 'naughty_or_nice'
require 'swot'
require 'iso_country_codes'
require 'csv'
require_relative 'gman/country_codes'
require_relative 'gman/locality'
require_relative 'gman/identifier'
require_relative 'gman/sanctions'

class Gman < NaughtyOrNice
  class << self

    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List but is limited to our whitelisted domains
    def list
      @list ||= PublicSuffix::List::parse(list_contents)
    end

    def config_path
      File.join(File.dirname(__FILE__), "../config")
    end

    # Returns the absolute path to the domain list
    def list_path
      File.join(config_path,"domains.txt")
    end

    def list_contents
      @list_contents ||= File.new(list_path, "r:utf-8").read
    end
  end

  # Checks if the input string represents a government domain
  #
  # Returns boolean true if a government domain
  def valid?
    # Ensure it's a valid domain
    return false unless PublicSuffix.valid?(".#{domain}")

    # Ensure non-edu
    return false if Swot::is_academic?(domain)

    # Check for locality by regex
    return true if locality?

    # check using public suffix's standard logic
    rule = Gman.list.find domain

    # domain is on the domain list and
    # domain is not explicitly blacklisted and
    # domain matches a standard public suffix list rule
    !rule.nil? && rule.type != :exception && rule.allow?(".#{domain}")
  end
end
