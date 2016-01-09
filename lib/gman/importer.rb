# Utility functions for parsing and manipulating public-suffix domain lists
# Only used in development and not loaded by default
require 'yaml'
require 'open-uri'
require 'resolv'
require 'logger'
require_relative '../gman'
require_relative './domain_list'

class Gman
  class Importer
    attr_accessor :domains

    # Known false positives from vendored lists
    BLACKLIST = %w(
      business.centurytel.net
      chesnee.net
      citlink.net
      egovlink.com
      emainehosting.com
      fantasyspringsresort.com
      frontiernet.net
      hartford-hwp.com
      homepages.sover.net
      htc.net
      koasekabenaki.org
      kstrom.net
      laworkforce.net
      mississippistateparks.reserveamerica.com
      mylocalgov.com
      myweb.cebridge.net
      ncstars.org
      neagrelations.org
      qis.net
      rootsweb.com
      showcase.netins.net
      valuworld.com
      wctc.net
      webconnections.net
      webpages.charter.net
    ).freeze

    def initialize(domains)
      @domains = DomainList.new(domains)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def normalize_domain(domain)
      domain = Gman.new(domain).to_s
      domain.to_s.downcase.strip.gsub(/^www./, '').gsub(/\/$/, '')
    end

    def valid_domain?(domain, options = {})
      return false if domain.empty?
      return reject(domain, 'home. regex')     if domain =~ /^home\./
      return reject(domain, 'user. regex')     if domain =~ /^users?\./
      return reject(domain, 'sites. regex')    if domain =~ /^sites?\./
      return reject(domain, 'weebly')          if domain =~ /weebly\.com$/
      return reject(domain, 'wordpress')       if domain =~ /wordpress\.com$/
      return reject(domain, 'govoffice')       if domain =~ /govoffice\d?\.com$/
      return reject(domain, 'homestead')       if domain =~ /homestead\.com$/
      return reject(domain, 'wix.com')         if domain =~ /wix\.com$/
      return reject(domain, 'blogspot.com')    if domain =~ /blogspot\.com$/
      return reject(domain, 'tripod.com')      if domain =~ /tripod\.com$/
      return reject(domain, 'squarespace.com') if domain =~ /squarespace\.com$/
      return reject(domain, 'github.io')       if domain =~ /github\.io$/
      return reject(domain, 'locality')        if domain =~ Gman::Locality::REGEX
      return reject(domain, 'blacklist')       if BLACKLIST.include?(domain)
      return reject(domain, 'duplicate')       if !options[:skip_dupe] && current.domains.include?(domain)
      return reject(domain, 'invalid')         unless PublicSuffix.valid?(".#{domain}")
      return reject(domain, 'academic')        if Swot.is_academic?(domain)

      if !options[:skip_dupe] && subdomain = current.domains.find { |c| domain =~ /\.#{Regexp.escape(c)}$/ }
        return reject(domain, "subdomain of #{subdomain}")
      end

      return reject(domain, 'unresolvable') if !options[:skip_resolve] && !domain_resolves?(domain)
      true
    end

    # if RECONCILING=true, return the reason,
    # rather than a bool and silence log output
    def reject(domain, reason)
      return reason if ENV['RECONCILING']
      logger.info "👎 `#{domain}`: #{reason}"
      false
    end

    def current
      @current ||= DomainList.current
    end

    def import(options)
      logger.info "Current: #{Gman::DomainList.current.count} domains"
      logger.info "Adding: #{domains.count} domains"

      normalize_domains!
      ensure_validity!(options)

      if domains.count == 0
        logger.info 'Nothing to add. Aborting'
        exit 0
      end

      add_to_current
      logger.info "New: #{current.count} domains"
    end

    def resolver
      @resolver ||= Resolv::DNS.new(nameserver: ['8.8.8.8', '8.8.4.4'])
    end

    # Verifies that the given domain has an MX record, and thus is valid
    def domain_resolves?(domain)
      domain = Addressable::URI.new(host: domain).normalize.host
      ip? || returns_record?(domain, 'NS') || returns_record?(domain, 'MX')
    end

    private

    def normalize_domains!
      domains.list.each do |_group, domains|
        domains.map! { |domain| normalize_domain(domain) }
      end
    end

    def ensure_validity!(options = {})
      domains.list.each do |_group, domains|
        domains.select! { |domain| valid_domain?(domain, options) }
      end
    end

    def add_to_current
      domains.list.each do |group, domains|
        current.list[group] ||= []
        current.list[group].concat domains
      end
      current.write
    end

    def ip?(domain)
      resolver.getaddress(domain)
    rescue Resolv::ResolvError
      false
    end

    def returns_record?(domain, type)
      type = Object.const_get "Resolv::DNS::Resource::IN::#{type}"
      resolver.getresource(domain, type)
    rescue Resolv::ResolvError
      false
    end
  end
end

class Gman
  def self.import(hash, options = {})
    Gman::Importer.new(hash).import(options)
  end
end
