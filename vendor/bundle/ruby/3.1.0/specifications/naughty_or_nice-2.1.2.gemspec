# -*- encoding: utf-8 -*-
# stub: naughty_or_nice 2.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "naughty_or_nice".freeze
  s.version = "2.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ben Balter".freeze]
  s.date = "2020-11-13"
  s.description = "Naughty or Nice simplifies the process of extracting domain information from a domain-like string (an email, a URL, etc.) and checking whether it meets criteria you specify.".freeze
  s.email = "ben.balter@github.com".freeze
  s.homepage = "http://github.com/benbalter/naughty_or_nice".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.26".freeze
  s.summary = "You've made the list. We'll help you check it twice. Given a domain-like string, verifies inclusion in a list you provide.".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.3"])
    s.add_runtime_dependency(%q<public_suffix>.freeze, [">= 3.0"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.0"])
    s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 2.0"])
  else
    s.add_dependency(%q<addressable>.freeze, ["~> 2.3"])
    s.add_dependency(%q<public_suffix>.freeze, [">= 3.0"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.9"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rubocop-performance>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rubocop-rspec>.freeze, ["~> 2.0"])
  end
end
