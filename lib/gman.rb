# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'naughty_or_nice'
require 'iso_country_codes'
require 'csv'
require_relative 'gman/version'
require_relative 'gman/country_codes'
require_relative 'gman/identifier'

class Gman
  include NaughtyOrNice

  autoload :DomainList, 'gman/domain_list'
  autoload :Importer,   'gman/importer'
  autoload :Locality,   'gman/locality'

  class << self
    def list
      @list ||= DomainList.new(path: list_path)
    end

    def academic_list
      @academic_list ||= DomainList.new(path: academic_list_path)
    end

    def config_path
      @config_path ||= File.expand_path '../config', File.dirname(__FILE__)
    end

    # Returns the absolute path to the domain list
    def list_path
      File.expand_path 'domains.txt', config_path
    end

    def academic_list_path
      File.expand_path 'vendor/academic.txt', config_path
    end
  end

  # Checks if the input string represents a government domain
  #
  # Returns boolean true if a government domain
  def valid?
    return @valid if defined?(@valid)

    @valid = valid_domain? && (locality? || public_suffix_valid?)
  end

  def locality?
    Locality.valid?(domain)
  end

  private

  # Overrides NaughtyOrNice#normalized_domain, which parses every input as a
  # URL. For an email address, the URL host can differ from the domain mail is
  # delivered to (e.g. "x@gsa.gov#"@example.com), so the domain after the last
  # @ must be the same host the URL parser sees.
  #
  # Returns the domain string, or nil
  def normalized_domain
    return if @text.match?(/[[:space:][:cntrl:]]/)
    return super unless email_like?

    host = @text.rpartition('@').last
    host if host == super
  end

  def email_like?
    @text.include?('@') && !%r{\Ahttps?://}.match?(@text)
  end

  def valid_domain?
    !domain.nil? && !academic?
  end

  def academic?
    return @academic if defined?(@academic)

    @academic = !domain.nil? && Gman.academic_list.valid?(to_s)
  end

  def public_suffix_valid?
    return @public_suffix_valid if defined?(@public_suffix_valid)

    @public_suffix_valid = Gman.list.valid?(to_s)
  end
end
