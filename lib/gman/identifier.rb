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

  # Column names follow CISA's current-full.csv (https://github.com/cisagov/dotgov-data),
  # which renamed its headers in 2026: "Agency" became "Organization name" and
  # "Organization" became "Suborganization name".
  def_hash_delegator :dotgov_listing, :'Organization name', :agency
  def_hash_delegator :dotgov_listing, :'Suborganization name', :organization
  def_hash_delegator :dotgov_listing, :City
  def_hash_delegator :dotgov_listing, :'Domain type'
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
    elsif dotgov_listing && dotgov_listing['State']
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

    domain_type.to_s.match?(/^Federal/i)
  end

  def city?
    if matches
      %w[ci town vil].include?(matches[3])
    elsif dotgov_listing
      domain_type.to_s.start_with?('City') # includes "City - Election"
    else
      false
    end
  end

  def county?
    if matches
      matches[3] == 'co'
    elsif dotgov_listing
      domain_type.to_s.start_with?('County') # includes "County - Election"
    else
      false
    end
  end

  def state?
    if matches
      matches[1] == 'state'
    elsif dotgov_listing
      domain_type.to_s.start_with?('State') # "State or territory", plus " - Election"
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

    match = Gman.list.public_suffix_list.find(domain.to_s, default: nil)
    @list_category = match && Gman.list.group_for(match.value)
  end

  def matches
    return @matches if defined? @matches

    @matches = domain.to_s.match(Locality::REGEX)
  end

  def dotgov_listing
    return @dotgov_listing if defined? @dotgov_listing
    return unless dotgov?

    @dotgov_listing = Gman.dotgov_index["#{domain.sld}.gov".downcase]
  end

  class << self
    def dotgov_list
      @dotgov_list ||= CSV.read(dotgov_list_path, headers: true)
    end

    # Hash of lowercase domain name => dotgov listing, for constant-time lookup
    def dotgov_index
      @dotgov_index ||= dotgov_list.to_h { |listing| [listing['Domain name'].downcase, listing] }
    end

    private

    def dotgov_list_path
      File.join Gman.config_path, 'vendor/dotgovs.csv'
    end
  end
end
