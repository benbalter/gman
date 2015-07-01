class Gman

  def type
    if state?
      :state
    elsif district?
      :district
    elsif cog?
      :cog
    elsif city?
      :city
    elsif federal?
      :federal
    elsif county?
      :county
    elsif list_category.nil?
      nil
    elsif list_category.include?("usagov")
      :unknown
    else
      list_category.to_sym
    end
  end

  def state
    if matches
      matches[4].upcase
    elsif dotgov_listing
      dotgov_listing["State"]
    elsif list_category
      matches = list_category.match(/usagov([A-Z]{2})/)
      matches[1] if matches
    end
  end

  def city
    dotgov_listing["City"] if dotgov_listing
  end

  def agency
    dotgov_listing["Agency"] if federal?
  end

  def dotgov?
    domain_parts.tld == "gov"
  end

  def federal?
    dotgov_listing && dotgov_listing["Domain Type"] == "Federal Agency"
  end

  def city?
    if matches
      %w[ci town vil].include?(matches[3])
    elsif dotgov_listing
      dotgov_listing["Domain Type"] == "City"
    end
  end

  def county?
    if matches
      matches[3] == "co"
    elsif dotgov_listing
      dotgov_listing["Domain Type"] == "County"
    end
  end

  def state?
    if matches
      matches[1] == "state"
    elsif dotgov_listing
      dotgov_listing["Domain Type"] == "State/Local Govt"
    end
  end

  def district?
    !!matches && matches[1] == "dst"
  end

  def cog?
    !!matches && matches[1] == "cog"
  end

  private

  def list_category
    @list_category ||= begin
      if match = Gman.list.find(domain)
        regex = Regexp.new "\/\/ ([^\\n]+)\\n?[^\/\/]*\\n#{Regexp.escape(match.name)}\\n", "im"
        matches = Gman.list_contents.match(regex)
        matches[1] if matches
      end
    end
  end

  def matches
    @matches ||= domain.match(LOCALITY_REGEX)
  end

  def self.dotgov_list_path
    File.join Gman.config_path, "vendor/dotgovs.csv"
  end

  def self.dotgov_list
    @dotgov_list ||= CSV.read(dotgov_list_path, :headers => true)
  end

  def dotgov_listing
    @dotgov_listing ||= Gman.dotgov_list.find { |d| d["Domain Name"].downcase == "#{domain_parts.sld}.gov" } if dotgov?
  end
end
