require File.join(File.dirname(__FILE__), 'helper')

VALID = [  "foo.gov",
            "http://foo.mil",
            "foo@bar.gc.ca",
            "foo.gov.au",
            "https://www.foo.gouv.fr",
            "foo@ci.champaign.il.us",
            "foo.bar.baz.gov.au",
            "foo@bar.gov.uk",
            ".gov",
            "foo.fed.us",
        ]

INVALID = [ "foo.bar.com",
            "bar@foo.biz",
            "http://www.foo.biz",
            "foo.uk",
            "gov",
            "foo@k12.champaign.il.us",
            "foo@kii.gov.by",
            "foo",
            "",
            nil,
            " ",
          ]

class TestGman < Minitest::Test

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

  should "not allow educational domains" do
    assert_equal false, Gman::valid?("foo@gwu.edu")
  end

  should "properly parse domains from strings" do
    assert_equal "github.gov", Gman::get_domain("foo@github.gov")
    assert_equal "foo.github.gov", Gman::get_domain("foo.github.gov")
    assert_equal "github.gov", Gman::get_domain("http://github.gov")
    assert_equal "github.gov", Gman::get_domain("https://github.gov")
    assert_equal ".gov", Gman::get_domain(".gov")
    assert_equal nil, Gman.get_domain("foo")
  end

  should "not err out on invalid domains" do
    assert_equal false, Gman.valid?("foo@gov.invalid")
    assert_equal "gov.invalid", Gman.get_domain("foo@gov.invalid")
    assert_equal nil, Gman.domain_parts("foo@gov.invalid")
  end

  should "return public suffix domain" do
    assert_equal PublicSuffix::Domain, Gman.domain_parts("whitehouse.gov").class
    assert_equal NilClass, Gman.domain_parts("foo.invalid").class
  end

  should "parse domain parts" do
    assert_equal "gov", Gman.domain_parts("foo@bar.gov").tld
    assert_equal "bar", Gman.domain_parts("foo.bar.gov").sld
    assert_equal "bar", Gman.domain_parts("https://foo.bar.gov").sld
    assert_equal "bar.gov", Gman.domain_parts("foo@bar.gov").domain
  end

  should "not err out on invalid hosts" do
    assert_equal nil, Gman.get_domain("</@foo.com")
  end

  should "returns the path to domains.txt" do
    assert_equal true, File.exists?(Gman.list_path)
  end

  should "parse the alpha2" do
    assert_equal "us", Gman.alpha2("whitehouse.gov")
    assert_equal "us", Gman.alpha2("army.mil")
    assert_equal "gb", Gman.alpha2("foo.gov.uk")
    assert_equal "ca", Gman.alpha2("gov.ca")
  end

  should "determine a domain's country" do
    assert_equal "United States", Gman.country("whitehouse.gov").name
    assert_equal "United States", Gman.country("army.mil").name
    assert_equal "United Kingdom", Gman.country("foo.gov.uk").name
    assert_equal "Canada", Gman.country("gc.ca").name
  end
end
