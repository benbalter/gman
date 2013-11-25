require 'public_suffix'
require 'yaml'
require 'swot'

module Gman

  class << self

    # Normalizes and checks if a given string represents a governemnt domain
    # Possible strings to test:
    #   ".gov"
    #   "foo.gov"
    #   "foo@bar.gov"
    #   "foo.gov.uk"
    #   "http://foo.bar.gov"
    #
    # Returns boolean true if a government domain and member of groups
    def valid?(text,groups=valid_domain_groups)
      return false if text.nil?
      domain = get_domain text

      # Ensure non-edu
      return false if Swot::is_academic?(domain)

      # check using public suffix's standard logic
      rule = whitelist(*groups).find domain
      return true if !rule.nil? && rule.allow?(domain)

      # also allow for explicit matches to domain list
      # but still make sure it's at least a valid domain
      return false unless PublicSuffix.valid? domain
      whitelist(*groups).rules.any? { |rule| rule.value == domain }
    end

    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List but is limited to our whitelisted domains
    def whitelist(*groups)
      @whitelist = []
      valid_domain_groups.each do |group|
        @whitelist.push(*domains_grouped[group]) if groups.include? group
      end
      PublicSuffix::List::parse( DomainList.new(@whitelist) )
    end

    # Get the FQDN name from a URL or email address.
    #
    # Returns a string with the FQDN; nil if there's an error.
    # Source: https://github.com/leereilly/swot/blob/master/lib/swot.rb#L190
    def get_domain(text)
      text.strip.downcase.match(domain_regex).captures.first
    rescue
      return nil
    end

    def valid_domain_groups
      domains_grouped.keys.collect { |k| k }
    end
    
    private

    # Source: https://github.com/leereilly/swot/blob/master/lib/swot.rb#L202
    def domain_regex
      /([^@\/:]+)[:\d]*$/
    end

    def domains_grouped
      @domains_grouped ||= YAML::load(File.open('lib/domains_grouped.yml'))
    end
  end


  # monkey patch for PublicSuffix::List
  class DomainList
    include Enumerable

    def initialize(members)
      @members = members
    end

    def each_line(&block)
      @members.each(&block)
    end
  end
end
