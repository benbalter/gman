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

end