class Gman
  class DomainList
    attr_accessor :list
    alias to_h list

    COMMENT_REGEX = %r{//[/\s]*(.*)$}i

    def initialize(list)
      @list = list.reject { |_group, domains| domains.compact.empty? }
    end

    def groups
      @groups ||= list.keys
    end

    def domains
      @domains ||= list.values.flatten.compact.sort.uniq
    end

    def count
      @count ||= domains.count
    end

    def alphabetize
      @list = @list.sort_by { |k, _v| k.downcase }.to_h
      @list.each { |_group, domains| domains.sort!.uniq! }
    end

    def write
      alphabetize
      File.write(Gman.list_path, to_public_suffix)
    end

    def to_public_suffix
      current_group = output = ''
      list.sort_by { |group, _domains| group.downcase }.each do |group, domains|
        if group != current_group
          output << "\n\n" unless current_group.empty? # first entry
          output << "// #{group}\n"
          current_group = group
        end
        output << domains.join("\n")
      end
      output
    end

    def self.current
      current = File.open(Gman.list_path).read
      DomainList.from_public_suffix(current)
    end

    def self.from_public_suffix(string)
      string = string.gsub(/\r\n?/, "\n").split("\n")
      hash = array_to_hash(string)
      DomainList.new(hash)
    end

    def parent_domain(domain)
      domains.find { |c| domain =~ /\.#{Regexp.escape(c)}$/ }
    end

    class << self
      private

      # Given an array of comments/domains in public suffix format
      # Converts to a hash in the form of :group => [domain1, domain2...]
      def array_to_hash(domains)
        domain_hash = {}
        group = ''
        domains.each do |line|
          if line =~ COMMENT_REGEX
            group = COMMENT_REGEX.match(line)[1]
          else
            safe_push(domain_hash, group, line.downcase)
          end
        end
        domain_hash
      end

      def safe_push(hash, key, value)
        return if value.empty?
        hash[key] ||= []
        hash[key].push value
      end
    end
  end
end
