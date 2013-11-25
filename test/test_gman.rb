require 'helper'
require 'swot'

VALID = [  "foo.gov",
            "http://foo.mil",
            "foo@bar.gc.ca",
            "foo.gov.au",
            "http://www.foo.gouv.fr",
            "foo@ci.champaign.il.us",
            "foo.bar.baz.gov.au",
            "foo@bar.gov.uk"
        ]

INVALID = [ "foo.bar.com",
            "bar@foo.biz",
            "http://www.foo.biz",
            "foo.uk",
            "gov",
            "foo@k12.champaign.il.us",
            "foo@kii.gov.by"
          ]

VALID_US = [
            "gsa.gov",
            "foo@nsa.mil",
            "http://foo.mil",
            "http://www.army.mil",
            "http://nsa.gov", 
            "foo.bar@gsa.gov", 
            "foo@businessusa.gov"
          ]

NON_FED_US = [
            "gouv.fr", 
            "gov.lv", 
            "http://www.gc.ca", 
            "gouv.ml", 
            "state.or.us", 
            "http://sfgov.org", 
            "foo@sfgov.org", 
            "google.com", 
            "http://yahoo.com",
            "this one isn't even a valid URI"
          ]

class TestGman < Test::Unit::TestCase

  should "recognize government email addresses and domains" do
    VALID.each do |test|
      assert_equal true, Gman::valid?(test), "#{test} should be detected as a valid government domain"
    end
  end

  should "not recognize non-government email addresses and domains" do
    INVALID.each do |test|
      assert_equal false, Gman::valid?(test), "#{test} should be detected as an invalid government domain"
    end
  end

  should "not contain any educational domains" do
    Gman.whitelist(*Gman.valid_domain_groups).each do |entry|
      assert_equal false, Swot::is_academic?(entry.name), "#{entry.name} is an academic domain"
    end
  end

  should "recognize valid US federal email addresses and domains when validating against 'US' group" do
    VALID_US.each do |test|
      assert_equal true, Gman::valid?(test, "us"), "#{test} should be detected as a valid US government domain"
    end
  end

  should "reject non-US federal email addresses and domains when validating against 'US' group" do
    NON_FED_US.each do |test|
      assert_equal false, Gman::valid?(test, "us"), "#{test} should be detected as an invalid US government domain"
    end
  end
end
