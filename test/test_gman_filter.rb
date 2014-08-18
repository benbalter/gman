HERE = File.dirname(__FILE__)
require File.join(HERE, 'helper')

class TestGmanFilter < Minitest::Test

  txt_path = File.join(HERE, "obama.txt")
  exec_path = File.join(HERE, "..", "bin", "gman_filter")

  should "remove non-gov/mil addresses" do
    filtered = `#{exec_path} < #{txt_path}`
    expected = %w(
      mr.senator@obama.senate.gov
      president@whitehouse.gov
      commander.in.chief@us.army.mil
    ).join("\n") + "\n"
    assert_equal filtered, expected
  end

end
