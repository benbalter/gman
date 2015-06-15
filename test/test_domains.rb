require File.join(File.dirname(__FILE__), 'helper')

class TestDomains < Minitest::Test

  WHITELIST = [ "non-us gov", "non-us mil", "US Federal"]
  DOMAINS = Gman::DomainList.current

  def whitelisted?(domain)
    WHITELIST.any? { |group| DOMAINS[group].include?(domain) }
  end

  should "only contain resolvable domains" do
    unresolvables = []
    importer = Gman::Importer.new({})
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      next if whitelisted? entry.name
      unresolvables.push entry.name unless importer.domain_resolves?(entry.name)
    end
    assert_equal [], unresolvables
  end

  should "not contain any educational domains" do
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      assert_equal false, Swot::is_academic?(entry.name), "#{entry.name} is an academic domain"
    end
  end

  should "not contain any invalid domains" do
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      assert_equal true, PublicSuffix.valid?("foo.#{entry.name}"), "#{entry.name} is not a valid domain"
    end
  end

  should "pass any url on the list" do
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      assert_equal true, Gman.valid?("http://foo.#{entry.name}/bar"), "http://foo.#{entry.name}/bar is not a valid"
    end
  end

  should "pass any email on the list" do
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      assert_equal true, Gman.valid?("foo@bar.#{entry.name}"), "foo@bar.#{entry.name} is not a valid"
    end
  end

  should "pass any domain on the list" do
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      assert_equal true, Gman.valid?("foo.#{entry.name}"), "foo.#{entry.name} is not a valid domain"
    end
  end

  should "not contain locality domains" do
    localities = []
    Parallel.each(Gman.list, :in_threads => 2) do |entry|
      localities.push entry.name if entry.name =~ Gman::LOCALITY_REGEX
    end
    assert_equal [], localities
  end
end
