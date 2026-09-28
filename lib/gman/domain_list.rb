# frozen_string_literal: true

class Gman
  class DomainList
    COMMENT_REGEX = %r{//[/\s]*(.*)$}i

    attr_writer :path, :contents

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
      alias from_string from_public_suffix
    end

    def initialize(path: nil, contents: nil, data: nil)
      @path     = path
      @contents = contents
      @data     = data.reject { |_, domains| domains.compact.empty? } if data
    end

    # Returns the raw content of the domain list as a string
    def contents
      @contents ||= if path
                      File.new(path, 'r:utf-8').read
                    else
                      to_s
                    end
    end

    # Replaces the list data, a hash of group => domains
    def data=(data)
      @data = data
      clear_cache
    end

    # Returns the parsed contents of the domain list as a hash
    # in the form for group => domains
    def data
      @data ||= string_to_hash(contents)
    end
    alias to_h data

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

    # domain is on the domain list
    def valid?(domain)
      rule = public_suffix_list.find(domain, default: nil)
      !(rule.nil? || rule.is_a?(PublicSuffix::Rule::Exception))
    end

    # Returns an array of strings representing the list groups
    def groups
      data.keys
    end

    # Return an array of strings representing all domains on the list
    def domains
      @domains ||= data.values.flatten.compact.sort.uniq.freeze
    end

    # Return the total number of domains in the list
    def count
      domains.count
    end

    # Alphabetize groups and domains within each group
    # We need to ensure exceptions appear after their coresponding rules
    def alphabetize
      self.data = data.sort_by { |k, _v| k.downcase }.to_h
      @data.each_value do |domains|
        domains.sort! { |a, b| sort_with_exceptions(a, b) }
        domains.uniq!
      end
      clear_cache
    end

    # Write the domain list to disk
    def write
      alphabetize
      File.write(path, to_public_suffix)
    end

    # The string representation of the domain list, in public suffix format
    def to_s
      current_group = output = +''
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
    alias to_public_suffix to_s

    # Returns the group a list entry belongs to, e.g., "US Federal" for "fcc.gov"
    # The entry must match the list verbatim. If an entry appears in more than
    # one group, the first group wins.
    def group_for(entry)
      group_index[entry]
    end

    # Given a domain, find any domain on the list that includes that domain
    # E.g., `fcc.gov` would be the parent of `data.fcc.gov`
    # If more than one list entry matches, returns the alphabetically first one
    def parent_domain(domain)
      suffixes = []
      domain.scan('.') { suffixes << Regexp.last_match.post_match }
      suffixes.select { |suffix| domain_set.include?(suffix) }.min
    end

    private

    # Clear values derived from data. Call after mutating data in place.
    def clear_cache
      @domains = @domain_set = @group_index = nil
    end

    def domain_set
      @domain_set ||= Set.new(domains)
    end

    # Hash of list entry => group, for constant-time group lookups
    def group_index
      @group_index ||= data.each_with_object({}) do |(group, domains), index|
        domains.each { |domain| index[domain] ||= group }
      end
    end

    # Parse a public-suffix formatted string into a hash of groups => [domains]
    def string_to_hash(string)
      return unless string

      lines = string_to_array(string)
      array_to_hash(lines)
    end

    def string_to_array(string)
      string.gsub(/\r\n?/, "\n").split("\n")
    end

    def array_to_hash(lines)
      domain_hash = {}
      group = ''
      lines.each do |line|
        if COMMENT_REGEX.match?(line)
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

    def sort_with_exceptions(left, right)
      if left.start_with?('!') && !right.start_with?('!')
        1
      elsif right.start_with?('!') && !left.start_with?('!')
        -1
      else
        left <=> right
      end
    end
  end
end
