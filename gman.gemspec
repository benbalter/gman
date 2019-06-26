# frozen_string_literal: true

require File.expand_path './lib/gman/version', File.dirname(__FILE__)

Gem::Specification.new do |s|
  s.name = 'gman'
  s.summary = <<-SUMMARY
    Check if a given domain or email address belong to a governemnt entity
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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end

  s.require_paths = ['lib']
  s.required_ruby_version = '~> 2.3'

  s.add_dependency('colored', '~> 1.2')
  s.add_dependency('iso_country_codes', '~> 0.6')
  s.add_dependency('naughty_or_nice', '= 2.1.1')
  s.add_dependency('public_suffix', '>= 3', '< 5')

  s.add_development_dependency('addressable', '~> 2.3')
  s.add_development_dependency('mechanize', '~> 2.7')
  s.add_development_dependency('parallel', '~> 1.6')
  s.add_development_dependency('pry', '~> 0.10')
  s.add_development_dependency('rspec', '~> 3.5')
  s.add_development_dependency('rubocop', '~> 0.37')
  s.add_development_dependency('ruby-prof', '~> 0.15')
  s.add_development_dependency('swot', '~> 1.0')
end
