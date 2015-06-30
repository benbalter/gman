class Gman
  class DomainList

    attr_accessor :list
    alias_method :to_h, :list

    COMMENT_REGEX = /\/\/[\/\s]*(.*)$/i

    def initialize(list)
      @list = list
    end

    def groups
      list.keys
    end

    def domains
      list.values.flatten
    end

    def count
      domains.count
    end

    def alphabetize
      @list = @list.sort_by { |k,v| k.downcase }.to_h
      @list.each { |group, domains| domains.sort!.uniq! }
    end

    def write
      File.write(Gman.list_path, to_public_suffix)
    end

    def to_public_suffix
      current_group = ""
      output = ""
      list.sort_by { |group, domains| group.downcase }.each do |group, domains|
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
      current = File.open(Gman::list_path).read
      DomainList.from_public_suffix(current)
    end

    def self.from_public_suffix(string)
      string = string.gsub(/\r\n?/, "\n").split("\n")
      hash = array_to_hash(string)
      DomainList.new(hash)
    end

    private

    # Given an array of comments/domains in public suffix format
    # Converts to a hash in the form of :group => [domain1, domain2...]
    def self.array_to_hash(domains)
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
  end
end
