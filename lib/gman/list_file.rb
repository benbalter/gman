class Gman
  class ListFile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    # domain is on the domain list and
    # domain is not explicitly blacklisted and
    # domain matches a standard public suffix list rule
    def valid?(domain)
      rule = list.find(domain)
      !rule.nil? && rule.type != :exception && rule.allow?(".#{domain}")
    end

    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List
    # but is limited to our whitelisted domains
    def list
      @list ||= PublicSuffix::List.parse(contents)
    end

    def contents
      @contents ||= File.new(path, 'r:utf-8').read
    end
  end
end
