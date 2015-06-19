require File.join(File.dirname(__FILE__), 'helper')

class TestGmanCountryCodes < Minitest::Test
  should "determine a domain's country" do
    assert_equal "United States of America", Gman.new("whitehouse.gov").country.name
    assert_equal "United States of America", Gman.new("army.mil").country.name
    assert_equal "United Kingdom of Great Britain and Northern Ireland", Gman.new("foo.gov.uk").country.name
    assert_equal "Canada", Gman.new("foo.gc.ca").country.name
  end

  should "not err out on an unknown country code" do
    assert_equal nil, Gman.new("foo.eu").country
  end
end
