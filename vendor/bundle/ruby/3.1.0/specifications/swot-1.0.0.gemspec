# -*- encoding: utf-8 -*-
# stub: swot 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "swot".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Lee Reilly".freeze]
  s.date = "2015-07-10"
  s.description = "Identify email addresses or domains names that belong to colleges or universities. Help automate the process of approving or rejecting academic discounts.".freeze
  s.email = "lee@leereilly.net".freeze
  s.extra_rdoc_files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.files = ["LICENSE.txt".freeze, "README.md".freeze]
  s.homepage = "https://github.com/leereilly/swot".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "Identify email addresses or domains names that belong to colleges or universities.".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<public_suffix>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<naughty_or_nice>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.12"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<jeweler>.freeze, ["~> 1.8"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 4.7.5"])
  else
    s.add_dependency(%q<public_suffix>.freeze, [">= 0"])
    s.add_dependency(%q<naughty_or_nice>.freeze, ["~> 2.0"])
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<jeweler>.freeze, ["~> 1.8"])
    s.add_dependency(%q<minitest>.freeze, ["~> 4.7.5"])
  end
end
