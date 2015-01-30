require_relative "helper"

class TestGmanBin < Minitest::Test

  def setup
    @output, @status = test_bin("whitehouse.gov")
  end

  should "parse the domain" do
    output, status = test_bin("bar.gov")
    assert_match /Domain  : bar.gov/, output

    output, status = test_bin("foo@bar.gov")
    assert_match /Domain  : bar.gov/, output

    output, status = test_bin("http://bar.gov/foo")
    assert_match /Domain  : bar.gov/, output
  end

  should "err on invalid domains" do
    output, status = test_bin("foo.invalid")
    assert_equal 1, status.exitstatus
    assert_match /Invalid domain/, output
  end

  should "err on non-government domains" do
    output, status = test_bin("github.com")
    assert_equal 1, status.exitstatus
    assert_match /Not a government domain/, output
  end

  should "know the type" do
    assert_match /federal/, @output
    assert_equal 0, @status.exitstatus
  end

  should "know the agency" do
    assert_match /Executive Office of the President/, @output
    assert_equal 0, @status.exitstatus
  end

  should "know the country" do
    assert_match /United States/, @output
    assert_equal 0, @status.exitstatus
  end

  should "know the city" do
    assert_match /Washington/, @output
    assert_equal 0, @status.exitstatus
  end

  should "know the state" do
    assert_match /DC/, @output
    assert_equal 0, @status.exitstatus
  end

  should "allow you to disable colorization" do
    output, status = test_bin("whitehouse.gov", "--no-color")
    refute_match /\[0;32;49m/, output
  end

  should "color by default" do
    assert_match /\[0;32;49m/, @output
  end

  should "show help text" do
    output, status = test_bin
    assert_match /Usage/i, output

    output, status = test_bin("")
    assert_match /Usage/i, output

    output, status = test_bin("--no-color")
    assert_match /Usage/i, output
  end

  should "know if a country is sanctioned" do
    output, status = test_bin "kim@pyongyang.gov.kp"
    assert_match /SANCTIONED/, output
  end
end
