# -*- encoding: utf-8 -*-
# stub: iso_country_codes 0.7.8 ruby lib

Gem::Specification.new do |s|
  s.name = "iso_country_codes".freeze
  s.version = "0.7.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Alex Rabarts".freeze]
  s.date = "2017-07-05"
  s.description = "ISO country code and currency library".freeze
  s.email = "alexrabarts@gmail.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze]
  s.files = ["README.rdoc".freeze]
  s.homepage = "http://github.com/alexrabarts/iso_country_codes".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "3.3.26".freeze
  s.summary = "Provides ISO 3166-1 country codes/names and ISO 4217 currencies.".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, ["~> 0"])
    s.add_development_dependency(%q<shoulda>.freeze, ["~> 0"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 0"])
    s.add_development_dependency(%q<nokogiri>.freeze, ["~> 0"])
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 0"])
    s.add_dependency(%q<shoulda>.freeze, ["~> 0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 0"])
  end
end
