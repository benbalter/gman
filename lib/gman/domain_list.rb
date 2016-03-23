class Gman
  class DomainList

    COMMENT_REGEX = %r{//[/\s]*(.*)$}i

    class << self
      # The current, government domain list
      def current
        DomainList.new(path: Gman.list_path)
      end

      def from_file(path)
        DomainList.new(path: path)
      end

      def from_hash(hash)
        DomainList.new(data: hash)
      end

      def from_public_suffix(string)
        DomainList.new(contents: string)
      end
      alias_method :from_string, :from_public_suffix
    end

    def initialize(path: nil, contents: nil, data: nil)
      @path     = path
      @contents = contents
      @data     = data.reject { |_, domains| domains.compact.empty? } if data
    end

    # Returns the raw content of the domain list as a string
    def contents
      @contents ||= begin
        File.new(path, 'r:utf-8').read if path
      end
    end

    # Returns the parsed contents of the domain list as a hash
    # in the form for group => domains
    def data
      @data ||= string_to_hash(contents)
    end
    alias_method :to_h, :data

    # Returns the path to the domain list on disk
    def path
      @path ||= Gman.list_path
    end

    # returns an instance of our custom public suffix list
    # list behaves like PublicSuffix::List
    # but is limited to our whitelisted domains
    def public_suffix_list
      @public_suffix_list ||= PublicSuffix::List.parse(contents)
    end

    # domain is on the domain list and
    # domain is not explicitly blacklisted and
    # domain matches a standard public suffix list rule
    def valid?(domain)
      rule = public_suffix_list.find(domain)
      !rule.nil? && rule.type != :exception && rule.allow?(".#{domain}")
    end

    # Returns an array of strings representing the list groups
    def groups
      data.keys
    end

    # Return an array of strings representing all domains on the list
    def domains
      data.values.flatten.compact.sort.uniq
    end

    # Return the total number of domains in the list
    def count
      domains.count
    end

    # Alphabetize groups and domains within each group
    def alphabetize
      @data = @data.sort_by { |k, _v| k.downcase }.to_h
      @data.each { |_group, domains| domains.sort!.uniq! }
    end

    # Write the domain list to disk
    def write
      alphabetize
      File.write(path, to_public_suffix)
    end

    # The string representation of the domain list, in public suffix format
    def to_s
      current_group = output = ''
      data.sort_by { |group, _| group.downcase }.each do |group, domains|
        if group != current_group
          output << "\n\n" unless current_group.empty? # first entry
          output << "// #{group}\n"
          current_group = group
        end
        output << domains.join("\n")
      end
      output
    end
    alias_method :to_public_suffix, :to_s

    # Given a domain, find any domain on the list that includes that domain
    # E.g., `fcc.gov` would be the parent of `data.fcc.gov`
    def parent_domain(domain)
      domains.find { |c| domain =~ /\.#{Regexp.escape(c)}$/ }
    end

    private

    # Parse a public-suffix formatted string into a hash of groups => [domains]
    def string_to_hash(string)
      return unless string
      lines = string.gsub(/\r\n?/, "\n").split("\n")
      domain_hash = {}
      group = ''
      lines.each do |line|
        if line =~ COMMENT_REGEX
          group = COMMENT_REGEX.match(line)[1]
        else
          safe_push(domain_hash, group, line.downcase)
        end
      end
      domain_hash
    end

    # Add a value to an array in a hash, creating the array if necessary
    # hash  - the hash
    # key   - the key within that hash to add the value to
    # value - the single value to push into the array at hash[key]
    def safe_push(hash, key, value)
      return if value.empty?
      hash[key] ||= []
      hash[key].push value
    end
  end
end
