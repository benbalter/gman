HERE = File.dirname(__FILE__)
require File.join(HERE, 'helper')

class TestGmanFilter < Minitest::Test
  txt_path = fixture_path 'obama.txt'
  exec_path = bin_path 'gman_filter'

  should 'remove non-gov/mil addresses' do
    output, _status = Open3.capture2e('bundle', 'exec', exec_path, txt_path)
    expected = %w(
      mr.senator@obama.senate.gov
      president@whitehouse.gov
      commander.in.chief@us.army.mil
    ).join("\n") + "\n"
    assert_equal output, expected
  end
end
