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
    Gman.list.each do |entry|
      assert_equal false, Swot::is_academic?(entry.name), "#{entry.name} is an academic domain"
    end
  end

  should "not contain any invalid domains" do
    Gman.list.each do |entry|
      assert_equal true, PublicSuffix.valid?("foo.#{entry.name}"), "#{entry.name} is not a valid domain"
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

  should "validate mx records when asked" do
    assert_equal true, Gman.valid?("foo@nasa.gov", true)
    assert_equal false, Gman.valid?("foo@github.gov", true)
    assert_equal true, Gman.valid?("foo@github.gov", false)
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

  should "not err out on invalid domains" do
    assert_equal false, Gman.valid?("foo@act.gov.au")
    assert_equal "act.gov.au", Gman.get_domain("foo@act.gov.au")
    assert_equal nil, Gman.domain_parts("foo@act.gov.au")
  end

  should "return public suffix domain" do
    assert_equal PublicSuffix::Domain, Gman.domain_parts("whitehouse.gov").class
    assert_equal NilClass, Gman.domain_parts("foo.bar").class
  end

  should "parse domain parts" do
    assert_equal "gov", Gman.domain_parts("foo@bar.gov").tld
    assert_equal "bar", Gman.domain_parts("foo.bar.gov").sld
    assert_equal "bar", Gman.domain_parts("https://foo.bar.gov").sld
    assert_equal "bar.gov", Gman.domain_parts("foo@bar.gov").domain
  end
end
