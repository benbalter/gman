class Gman
  def type
    [:state, :district, :cog, :city, :federal, :county].each do |type|
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
    elsif dotgov_listing
      dotgov_listing['State']
    elsif list_category
      matches = list_category.match(/usagov([A-Z]{2})/)
      matches[1] if matches
    end
  end

  def city
    dotgov_listing['City'] if dotgov_listing
  end

  def agency
    dotgov_listing['Agency'] if federal?
  end

  def dotgov?
    domain.tld == 'gov'
  end

  def federal?
    dotgov_listing && dotgov_listing['Domain Type'] == 'Federal Agency'
  end

  def city?
    if matches
      %w(ci town vil).include?(matches[3])
    elsif dotgov_listing
      dotgov_listing['Domain Type'] == 'City'
    end
  end

  def county?
    if matches
      matches[3] == 'co'
    elsif dotgov_listing
      dotgov_listing['Domain Type'] == 'County'
    end
  end

  def state?
    if matches
      matches[1] == 'state'
    elsif dotgov_listing
      dotgov_listing['Domain Type'] == 'State/Local Govt'
    end
  end

  def district?
    matches && matches[1] == 'dst'
  end

  def cog?
    matches && matches[1] == 'cog'
  end

  private

  def list_category
    @list_category ||= begin
      match = Gman.list.public_suffix_list.find(domain.to_s)
      return unless match
      regex = %r{// ([^\n]+)\n?[^/]*\n#{Regexp.escape(match.name)}\n}im
      matches = Gman.list.contents.match(regex)
      matches[1] if matches
    end
  end

  def matches
    return @matches if defined? @matches
    @matches = domain.to_s.match(Locality::REGEX)
  end

  def dotgov_listing
    return @dotgov_listing if defined? @dotgov_listing
    return unless dotgov?
    @dotgov_listing = Gman.dotgov_list.find do |listing|
      listing['Domain Name'].casecmp("#{domain.sld}.gov") == 0
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
