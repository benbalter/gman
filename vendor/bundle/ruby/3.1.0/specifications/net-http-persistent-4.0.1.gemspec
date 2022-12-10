# -*- encoding: utf-8 -*-
# stub: net-http-persistent 4.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "net-http-persistent".freeze
  s.version = "4.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/drbrain/net-http-persistent" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Eric Hodel".freeze]
  s.date = "2021-01-12"
  s.description = "Manages persistent connections using Net::HTTP including a thread pool for\nconnecting to multiple hosts.\n\nUsing persistent HTTP connections can dramatically increase the speed of HTTP.\nCreating a new HTTP connection for every request involves an extra TCP\nround-trip and causes TCP congestion avoidance negotiation to start over.\n\nNet::HTTP supports persistent connections with some API methods but does not\nmake setting up a single persistent connection or managing multiple\nconnections easy.  Net::HTTP::Persistent wraps Net::HTTP and allows you to\nfocus on how to make HTTP requests.".freeze
  s.email = ["drbrain@segment7.net".freeze]
  s.extra_rdoc_files = ["History.txt".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["History.txt".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.homepage = "https://github.com/drbrain/net-http-persistent".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.3.26".freeze
  s.summary = "Manages persistent connections using Net::HTTP including a thread pool for connecting to multiple hosts".freeze

  s.installed_by_version = "3.3.26" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<connection_pool>.freeze, ["~> 2.2"])
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_development_dependency(%q<hoe-bundler>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<hoe-travis>.freeze, ["~> 1.4", ">= 1.4.1"])
    s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_development_dependency(%q<hoe>.freeze, ["~> 3.22"])
  else
    s.add_dependency(%q<connection_pool>.freeze, ["~> 2.2"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.14"])
    s.add_dependency(%q<hoe-bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.4", ">= 1.4.1"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.22"])
  end
end
