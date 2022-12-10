# frozen_string_literal: true

require 'parallel'
require 'open3'

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed
end

require_relative '../lib/gman'
require_relative '../lib/gman/domain_list'
require_relative '../lib/gman/importer'

def fixture_path(fixture)
  File.expand_path "./fixtures/#{fixture}", File.dirname(__FILE__)
end

def stubbed_list_path
  File.expand_path './fixtures/domains.txt', File.dirname(__FILE__)
end

def with_env(key, value)
  old_env = ENV.fetch(key, nil)
  ENV[key] = value
  yield
  ENV[key] = old_env
end
