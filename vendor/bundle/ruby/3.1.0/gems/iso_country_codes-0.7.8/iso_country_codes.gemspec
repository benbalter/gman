# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{iso_country_codes}
  s.version = File.read('VERSION').strip
  s.authors = ["Alex Rabarts"]
  s.description = %q{ISO country code and currency library}
  s.summary = %q{Provides ISO 3166-1 country codes/names and ISO 4217 currencies.}
  s.homepage = %q{http://github.com/alexrabarts/iso_country_codes}
  s.email = %q{alexrabarts@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ['lib']
  s.license = 'MIT'

  ['bundler', 'shoulda', 'mocha', 'nokogiri'].each do |gem|
    s.add_development_dependency gem, '~> 0'
  end
end
