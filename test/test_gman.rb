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
            "state.il.us",
            "foo@af.mil",
            "gov.in"
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

  Parallel.each(VALID, :in_threads => 2) do |domain|
    should "recognize #{domain} as a government domain" do
      assert Gman::valid?(domain)
    end
  end

  Parallel.each(INVALID, :in_threads => 2) do |domain|
    should "recognize #{domain} as a non-government domain" do
      refute Gman::valid?(domain)
    end
  end

  should "not allow educational domains" do
    assert_equal false, Gman::valid?("foo@gwu.edu")
  end

  should "returns the path to domains.txt" do
    assert_equal true, File.exists?(Gman.list_path)
  end
end
