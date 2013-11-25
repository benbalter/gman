require 'helper'

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

class TestGman < Test::Unit::TestCase
  should "recognize government email addresses and domains" do
    VALID.each do |test|
      assert_equal true, Gman::valid?(test), "#{test} should be detected as a valid government domain"
    end
    INVALID.each do |test|
      assert_equal false, Gman::valid?(test), "#{test} should be detected as an invalid government domain"
    end
  end
end
