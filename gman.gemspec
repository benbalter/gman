Gem::Specification.new do |s|
  s.name = "gman"
  s.summary = "Check if a given domain or email address belong to a governemnt entity"
  s.description = "A ruby gem to check if the owner of a given email address is working for THE MAN."
  s.version = '4.0.0'
  s.authors = ["Ben Balter"]
  s.email = "ben.balter@github.com"
  s.homepage = "https://github.com/benbalter/gman"
  s.licenses = ["MIT"]

  s.files = [
    "LICENSE",
    "lib/gman.rb",
    "lib/domains.txt",
    "lib/gman/country_codes.rb",
    "lib/gman/locality.rb",
    "bin/gman_filter"
  ]

  s.executables << "gman_filter"

  s.require_paths = ["lib"]
  s.add_dependency( "swot", '~> 0.3.1' )
  s.add_dependency( "iso_country_codes", "~> 0.4" )
  s.add_dependency( "naughty_or_nice", "~> 0.0" )

  s.add_development_dependency( "rake" )
  s.add_development_dependency( "shoulda" )
  s.add_development_dependency( "rdoc" )
  s.add_development_dependency( "bundler" )
end
