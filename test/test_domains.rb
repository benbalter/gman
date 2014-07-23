require File.join(File.dirname(__FILE__), 'helper')

class TestDomains < Minitest::Test

  WHITELIST = [ "non-us gov", "non-us mil", "US Federal"]
  DOMAINS = Gman::Parser.file_to_hash(Gman.list_path)

  def whitelisted?(domain)
    WHITELIST.each do |group|
      return true if DOMAINS[group].include? domain
    end
    false
  end

  should "only contain resolvable domains" do
    unresolvables = []
    Gman.list.each do |entry|
      next if whitelisted? entry.name
      resolves = Gman::Parser.domain_resolves?(entry.name)
      unresolvables.push entry.name unless resolves
    end
    assert_equal [], unresolvables
  end

  should "not contain any educational domains" do
    Gman.list.each do |entry|
      assert_equal false, Swot::is_academic?(entry.name), "#{entry.name} is an academic domain"
    end
  end

  should "not contain any invalid domains" do
    Gman.list.each do |entry|
      assert_equal true, PublicSuffix.valid?("foo.#{entry.name}"), "#{entry.name} is not a valid domain"
    end
  end

  should "pass any url on the list" do
    Gman.list.each do |entry|
      assert_equal true, Gman.valid?("http://foo.#{entry.name}/bar"), "http://foo.#{entry.name}/bar is not a valid"
    end
  end

  should "pass any email on the list" do
    Gman.list.each do |entry|
      assert_equal true, Gman.valid?("foo@bar.#{entry.name}"), "foo@bar.#{entry.name} is not a valid"
    end
  end

  should "pass any domain on the list" do
    Gman.list.each do |entry|
      assert_equal true, Gman.valid?("foo.#{entry.name}"), "foo.#{entry.name} is not a valid domain"
    end
  end

  should "identify the coutnry for any domain on the list" do
    Gman.list.each do |entry|
      Gman.new("foo.#{entry.name}").country.name
    end
  end
end
