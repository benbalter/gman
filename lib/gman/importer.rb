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
    attr_accessor :domain_list

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

    REGEX_CHECKS = {
      'home. regex'     => /^home\./,
      'user. regex'     => /^users?\./,
      'sites. regex'    => /^sites?\./,
      'weebly'          => /weebly\.com$/,
      'wordpress'       => /wordpress\.com$/,
      'govoffice'       => /govoffice\d?\.com$/,
      'homestead'       => /homestead\.com$/,
      'wix.com'         => /wix\.com$/,
      'blogspot.com'    => /blogspot\.com$/,
      'tripod.com'      => /tripod\.com$/,
      'squarespace.com' => /squarespace\.com$/,
      'github.io'       => /github\.io$/,
      'tumblr'          => /tumblr\.com$/,
      'locality'        => Gman::Locality::REGEX
    }.freeze

    def initialize(domains)
      @domain_list = DomainList.new(data: domains)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def normalize_domain(domain)
      domain = Gman.new(domain).to_s
      domain.to_s.downcase.strip.gsub(/^www./, '').gsub(%r{/$}, '')
    end

    def valid_domain?(domain, options = {})
      return false if !options[:skip_dupe] && !ensure_not_dupe(domain)
      return false unless ensure_valid(domain)
      return false if !options[:skip_resolve] && !ensure_resolves(domain)
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

    def import(options = {})
      logger.info "Current: #{Gman::DomainList.current.count} domains"
      logger.info "Adding: #{domain_list.count} domains"

      normalize_domains!
      ensure_validity!(options)

      add_to_current
      logger.info "New: #{current.count} domains"
    end

    def resolver
      @resolver ||= Resolv::DNS.new(nameserver: ['8.8.8.8', '8.8.4.4'])
    end

    # Verifies that the given domain has an MX record, and thus is valid
    def domain_resolves?(domain)
      domain = Addressable::URI.new(host: domain).normalize.host
      return true if ip?(domain)
      returns_record?(domain, 'NS') || returns_record?(domain, 'MX')
    end

    private

    def ensure_regex(domain)
      REGEX_CHECKS.each do |msg, regex|
        return reject(domain, msg) if domain =~ regex
      end
      true
    end

    def ensure_valid(domain)
      return false if domain.empty?
      if BLACKLIST.include?(domain)
        reject(domain, 'blacklist')
      elsif !PublicSuffix.valid?(".#{domain}")
        reject(domain, 'invalid')
      elsif Swot.is_academic?(domain)
        reject(domain, 'academic')
      else
        ensure_regex(domain)
      end
    end

    def ensure_resolves(domain)
      return reject(domain, 'unresolvable') unless domain_resolves?(domain)
      true
    end

    def ensure_not_dupe(domain)
      return true unless dupe?(domain)
      if current.domains.include?(domain)
        reject(domain, 'duplicate')
      else
        parent = current.parent_domain(domain)
        reject(domain, "subdomain of #{parent}")
      end
    end

    def dupe?(domain)
      current.domains.include?(domain) || current.parent_domain(domain)
    end

    def normalize_domains!
      domain_list.to_h.each do |_group, domains|
        domains.map! { |domain| normalize_domain(domain) }
        domains.uniq!
      end
    end

    def ensure_validity!(options = {})
      domain_list.data.each do |_group, domains|
        domains.select! { |domain| valid_domain?(domain, options) }
      end
    end

    def add_to_current
      domain_list.data.each do |group, domains|
        current.data[group] ||= []
        current.data[group].concat domains
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
