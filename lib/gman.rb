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
    @valid ||= begin
      return false unless valid_domain?
      return false if academic?
      locality? || public_suffix_valid?
    end
  end

  def locality?
    Locality.valid?(domain)
  end

  private

  def valid_domain?
    @valid_domains ||= !domain.nil? && !academic?
  end

  def academic?
    @academic ||= domain && Gman.academic_list.valid?(to_s)
  end

  def public_suffix_valid?
    @public_suffix_valid ||= Gman.list.valid?(to_s)
  end
end
