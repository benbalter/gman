# Utility functions for parsing and manipulating public-suffix formatted domain lists
require 'net/dns'
require 'net/dns/resolver'

class Gman < NaughtyOrNice
  class Parser

    COMMENT_REGEX = /\/\/[\/\s]*(.*)$/i

    class << self

      # Given a public-suffix list formatted file
      # Converts to a hash in the form of :group => [domain1, domain2...]
      def file_to_hash(file)
        array_to_hash(file_to_array(file))
      end

      # Given a public-suffix list formatted file
      # Convert it into an array of comments and domains representing each line
      def file_to_array(file)
        domains = File.open(file).read
        domains.gsub! /\r\n?/, "\n" # Normalize line endings
        domains = domains.split("\n")
      end

      # Given an array of comments/domains in public suffix format
      # Converts to a hash in the form of :group => [domain1, domain2...]
      def array_to_hash(domains)
        group = ""
        domain_hash = {}
        domains.each do |line|
          next if line.empty?
          if match = COMMENT_REGEX.match(line)
            group = match[1]
          else
            domain_hash[group] = [] if domain_hash[group].nil?
            domain_hash[group].push line.downcase
          end
        end
        domain_hash
      end

      def resolver
        @resolver ||= begin
          resolver = Net::DNS::Resolver.new
          resolver.nameservers = ["8.8.8.8","8.8.4.4", "208.67.222.222", "208.67.220.220"]
          resolver
        end
      end

      # Verifies that the given domain has an MX record, and thus is valid
      def domain_resolves?(domain)
        resolver.search(domain).header.anCount > 0 ||
        resolver.search(domain, Net::DNS::NS).header.anCount > 0 ||
        resolver.search(domain, Net::DNS::MX).header.anCount > 0
      end
    end
  end
end
