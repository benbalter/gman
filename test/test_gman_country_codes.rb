require File.join(File.dirname(__FILE__), 'helper')

class TestGmanCountryCodes < Minitest::Test
  should "determine a domain's country" do
    assert_equal "United States", Gman.new("whitehouse.gov").country.name
    assert_equal "United States", Gman.new("army.mil").country.name
    assert_equal "United Kingdom", Gman.new("foo.gov.uk").country.name
    assert_equal "Canada", Gman.new("foo.gc.ca").country.name
  end
end
