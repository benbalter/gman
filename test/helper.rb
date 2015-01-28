require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'parallel'
require 'open3'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'gman'
require 'net/dns'
require 'net/dns/resolver'
require './lib/gman/parser'

def test_bin(*args)
  output, status = Open3.capture2e("bundle", "exec", "gman", *args)
end
