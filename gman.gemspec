# frozen_string_literal: true

require File.expand_path './lib/gman/version', File.dirname(__FILE__)

Gem::Specification.new do |s|
  s.name = 'gman'
  s.summary = <<-SUMMARY
    Check if a given domain or email address belong to a government entity
  SUMMARY
  s.description = <<-DESC
    A ruby gem to check if the owner of a given email address is working for
    THE MAN.
  DESC
  s.version = Gman::VERSION
  s.authors = ['Ben Balter']
  s.email = 'ben.balter@github.com'
  s.homepage = 'https://github.com/benbalter/gman'
  s.licenses = ['MIT']

  s.files = Dir['lib/**/*.rb', 'bin/*', 'config/**/*', 'LICENSE', 'docs/README.md']
  s.bindir = 'bin'
  s.executables = %w[gman gman_filter]

  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.3'

  s.add_dependency('csv', '~> 3.0')
  s.add_dependency('iso_country_codes', '~> 0.6')
  s.add_dependency('naughty_or_nice', '>= 2.1.1')
  s.add_dependency('public_suffix', '>= 3.0')

  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['homepage_uri'] = 'https://github.com/benbalter/gman'
  s.metadata['source_code_uri'] = 'https://github.com/benbalter/gman'
  s.metadata['bug_tracker_uri'] = 'https://github.com/benbalter/gman/issues'
  s.metadata['changelog_uri'] = 'https://github.com/benbalter/gman/releases'
end
