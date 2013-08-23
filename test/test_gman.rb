require 'helper'

VALID = ["foo.gov", "http://foo.mil", "foo@bar.gc.ca", "foo.gov.au", "http://www.foo.gouv.fr"]
INVALID = ["foo.bar.com", "bar@foo.biz", "http://www.foo.biz", "foo.uk", "gov"]

class TestGman < Test::Unit::TestCase
  should "recognize government email addresses and domains" do
    VALID.each do |test|
      assert_equal Gman::is_government?(test), true
    end
    INVALID.each do |test|
      assert_equal Gman::is_government?(test), false
    end
  end
end
