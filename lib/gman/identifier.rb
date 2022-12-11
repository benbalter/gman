# frozen_string_literal: true

class Gman
  # Defines an instance method that delegates to a hash's key
  #
  # hash_method -  a symbol representing the instance method to delegate to. The
  #                instance method should return a hash or respond to #[]
  # key         - the key to call within the hash
  # method      - (optional) the instance method the key should be aliased to.
  #               If not specified, defaults to the hash key
  # default     - (optional) value to return if value is nil (defaults to nil)
  #
  # Returns a symbol representing the instance method
  def self.def_hash_delegator(hash_method, key, method = nil, default = nil)
    method ||= key.to_s.downcase.sub(' ', '_')
    define_method(method) do
      hash = send(hash_method)
      if hash.respond_to? :[]
        hash[key.to_s] || default
      else
        default
      end
    end
  end

  def_hash_delegator :dotgov_listing, :Agency
  def_hash_delegator :dotgov_listing, :Organization
  def_hash_delegator :dotgov_listing, :City
  def_hash_delegator :dotgov_listing, :'Domain Type'
  private :domain_type

  def type
    %i[state district cog city federal county].each do |type|
      return type if send "#{type}?"
    end
    return if list_category.nil?

    if list_category.include?('usagov')
      :unknown
    else
      list_category.to_sym
    end
  end

  def state
    if matches
      matches[4].upcase
    elsif dotgov_listing['State']
      dotgov_listing['State']
    elsif list_category
      matches = list_category.match(/usagov([A-Z]{2})/)
      matches[1] if matches
    end
  end

  def dotgov?
    domain.tld == 'gov'
  end

  def federal?
    return false unless dotgov_listing

    domain_type =~ /^Federal/i
  end

  def city?
    if matches
      %w[ci town vil].include?(matches[3])
    elsif dotgov_listing
      domain_type == 'City'
    else
      false
    end
  end

  def county?
    if matches
      matches[3] == 'co'
    elsif dotgov_listing
      domain_type == 'County'
    else
      false
    end
  end

  def state?
    if matches
      matches[1] == 'state'
    elsif dotgov_listing
      domain_type == 'State/Local Govt' || domain_type == 'State'
    else
      false
    end
  end

  def district?
    return false unless matches

    matches[1] == 'dst'
  end

  def cog?
    return false unless matches

    matches[1] == 'cog'
  end

  private

  def list_category
    return @list_category if defined?(@list_category)

    match = Gman.list.public_suffix_list.find(domain.to_s)
    return @list_category = nil unless match

    regex = %r{// ([^\n]+)\n?[^/]*\n#{Regexp.escape(match.value)}\n}im
    matches = Gman.list.contents.match(regex)
    @list_category = matches ? matches[1] : nil
  end

  def matches
    return @matches if defined? @matches

    @matches = domain.to_s.match(Locality::REGEX)
  end

  def dotgov_listing
    return @dotgov_listing if defined? @dotgov_listing
    return unless dotgov?

    @dotgov_listing = Gman.dotgov_list.find do |listing|
      listing['Domain Name'].casecmp("#{domain.sld}.gov").zero?
    end
  end

  class << self
    def dotgov_list
      @dotgov_list ||= CSV.read(dotgov_list_path, headers: true)
    end

    private

    def dotgov_list_path
      File.join Gman.config_path, 'vendor/dotgovs.csv'
    end
  end
end
