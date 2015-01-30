require_relative "helper"

class TestGmanSanctions < Minitest::Test

  should "know when a country isn't sanctioned" do
    refute Gman.new("whitehouse.gov").sanctioned?
  end

  should "know when a country is sanctioned" do
    assert Gman.new("kim@pyongyang.gov.kp").sanctioned?
  end

  should "not err on invalid domains" do
    assert_equal nil, Gman.new("domain.invalid").sanctioned?
  end

  should "work with non-governemnt domains" do
    assert Gman.new("foo@bar.co.kp").sanctioned?
  end
end
