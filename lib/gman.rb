require 'naughty_or_nice'
require 'swot'
require 'iso_country_codes'
require_relative 'gman/country_codes'
require_relative 'gman/locality'

class Gman < NaughtyOrNice
  class << self
    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List but is limited to our whitelisted domains
    def list
      @list ||= PublicSuffix::List::parse(File.new(list_path, "r:utf-8"))
    end

    # Returns the absolute path to the domain list
    def list_path
      File.join(File.dirname(__FILE__), "../config/domains.txt")
    end
  end

  # Checks if the input string represents a government domain
  #
  # Returns boolean true if a government domain
  def valid?
    # Ensure it's a valid domain
    return false unless PublicSuffix.valid?(domain)

    # Ensure non-edu
    return false if Swot::is_academic?(domain)

    # Check for locality by regex
    return true if locality?

    # check using public suffix's standard logic
    rule = Gman.list.find domain
    return true if !rule.nil? && rule.allow?(domain)

    # also allow for explicit matches to domain list
    Gman.list.rules.any? { |rule| rule.value == domain }
  end
end
