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
    assert_equal "github.gov", Gman.new("foo@github.gov").domain
    assert_equal "foo.github.gov", Gman::new("foo.github.gov").domain
    assert_equal "github.gov", Gman::new("http://github.gov").domain
    assert_equal "github.gov", Gman::new("https://github.gov").domain
    assert_equal ".gov", Gman::new(".gov").domain
    assert_equal nil, Gman.new("foo").domain
  end

  should "not err out on invalid domains" do
    assert_equal false, Gman.valid?("foo@gov.invalid")
    assert_equal "gov.invalid", Gman.new("foo@gov.invalid").domain
    assert_equal nil, Gman.new("foo@gov.invalid").domain_parts
  end

  should "return public suffix domain" do
    assert_equal PublicSuffix::Domain, Gman.new("whitehouse.gov").domain_parts.class
    assert_equal NilClass, Gman.new("foo.invalid").domain_parts.class
  end

  should "parse domain parts" do
    assert_equal "gov", Gman.new("foo@bar.gov").domain_parts.tld
    assert_equal "bar", Gman.new("foo.bar.gov").domain_parts.sld
    assert_equal "bar", Gman.new("https://foo.bar.gov").domain_parts.sld
    assert_equal "bar.gov", Gman.new("foo@bar.gov").domain_parts.domain
  end

  should "not err out on invalid hosts" do
    assert_equal nil, Gman.new("</@foo.com").domain
  end

  should "returns the path to domains.txt" do
    assert_equal true, File.exists?(Gman.list_path)
  end

  should "parse the alpha2" do
    assert_equal "us", Gman.new("whitehouse.gov").alpha2
    assert_equal "us", Gman.new("army.mil").alpha2
    assert_equal "gb", Gman.new("foo.gov.uk").alpha2
    assert_equal "ca", Gman.new("gov.ca").alpha2
  end

  should "determine a domain's country" do
    assert_equal "United States", Gman.new("whitehouse.gov").country.name
    assert_equal "United States", Gman.new("army.mil").country.name
    assert_equal "United Kingdom", Gman.new("foo.gov.uk").country.name
    assert_equal "Canada", Gman.new("foo.gc.ca").country.name
  end

  should "recognize research domains" do
    assert_equal true, Gman.research?("foo@lanl.gov")
    assert_equal true, Gman.research?("bar@jpl.nasa.gov")
  end

  should "not recognize non-research domains as research" do
    assert_equal false, Gman.research?("foo@bar.gov.uk")
    assert_equal false, Gman.research?("asdf")
    assert_equal false, Gman.research?("foo@github.com")
  end
end
