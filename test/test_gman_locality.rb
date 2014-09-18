require File.join(File.dirname(__FILE__), 'helper')

class TestGmanLocality < Minitest::Test
  should "parse the alpha2" do
    assert_equal "us", Gman.new("whitehouse.gov").alpha2
    assert_equal "us", Gman.new("army.mil").alpha2
    assert_equal "gb", Gman.new("foo.gov.uk").alpha2
    assert_equal "ca", Gman.new("gov.ca").alpha2
  end
end
