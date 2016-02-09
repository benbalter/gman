require 'rubygems'
require 'bundler'
require 'minitest/autorun'
require 'parallel'
require 'open3'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require_relative '../lib/gman'
require_relative '../lib/gman/domain_list'
require_relative '../lib/gman/importer'

def bin_path(cmd = 'gman')
  File.expand_path "../bin/#{cmd}", File.dirname(__FILE__)
end

def test_bin(*args)
  Open3.capture2e('bundle', 'exec', bin_path, *args)
end

def fixture_path(fixture)
  File.expand_path "./fixtures/#{fixture}", File.dirname(__FILE__)
end

def with_env(key, value)
  old_env = ENV[key]
  ENV[key] = value
  yield
  ENV[key] = old_env
end
