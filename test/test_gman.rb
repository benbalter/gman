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
            "foo.state.il.us",
            "state.il.us"
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
            "foo.city.il.us",
            "foo.ci.il.us",
            "foo.zx.us"
          ]

class TestGman < Minitest::Test

  should "recognize government email addresses and domains" do
    Parallel.each(VALID, :in_threads => 2) do |test|
      assert_equal true, Gman::valid?(test), "#{test} should be detected as a valid government domain"
    end
  end

  should "not recognize non-government email addresses and domains" do
    Parallel.each(INVALID, :in_threads => 2) do |test|
      assert_equal false, Gman::valid?(test), "#{test} should be detected as an invalid government domain"
    end
  end

  should "not allow educational domains" do
    assert_equal false, Gman::valid?("foo@gwu.edu")
  end

  should "returns the path to domains.txt" do
    assert_equal true, File.exists?(Gman.list_path)
  end

end
