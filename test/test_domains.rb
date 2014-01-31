require File.join(File.dirname(__FILE__), 'helper')

class TestRemote < Test::Unit::TestCase

  def domain_resolves?(domain)
    res = Net::DNS::Resolver.new
    res.nameservers = ["8.8.8.8","8.8.4.4", "208.67.222.222", "208.67.220.220"]
    packet = res.search(domain, Net::DNS::NS)
    packet.header.anCount > 0
  end

  should "only contain resolvable domains" do
    Gman.list.each do |entry|
      assert_equal true, domain_resolves?(entry.name), "Could not resolve #{entry.name}"
    end
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

end
