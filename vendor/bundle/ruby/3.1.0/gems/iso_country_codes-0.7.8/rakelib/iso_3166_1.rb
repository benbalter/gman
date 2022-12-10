require 'nokogiri'
require 'open-uri'
require 'erubis'
require 'yaml'

class IsoCountryCodes
  module Task
    module UpdateCodes
      def self.get
        doc    = Nokogiri::HTML.parse(open('https://en.wikipedia.org/wiki/ISO_3166-1'), nil, 'UTF-8')
        codes  = {}
        td_map = {
          :name    => 1,
          :alpha2  => 2,
          :alpha3  => 3,
          :numeric => 4
        }

        code_labels = td_map.keys

        doc.search('table.wikitable.sortable tr').each do |row|
          value_hash = {}

          code_labels.each do |key|
            selector = "td:nth-of-type(#{td_map[key]})"
            selector << ' a' if key == :name

            value = row.search(selector).
                        reject { |el| el.parent.name == 'sup' }.
                        map(&:text).join.strip

            next if value == ''

            # This is a terrible hack to skip the first table of the
            # Wikipedia page, under "Naming and disputes".  The
            # giveaway is that this table doesn't include a "Numeric
            # code" field.
            if key == :numeric
              next unless value.to_i > 0
            end

            value_hash[key] = value

            if value_hash.length == code_labels.length - 1
              value_hash.keys.each do |value_hash_key|
                codes[value_hash[value_hash_key]] = value_hash if value_hash_key == :alpha3
              end
            end
          end
        end

        codes = recurse_merge(codes, self.exceptions)

        to_ruby(codes) if codes
      end

      def self.to_ruby(codes)
        tmpl  = File.read(File.join(File.dirname(__FILE__), 'iso_3166_1.rb.erb'))
        eruby = Erubis::Eruby.new(tmpl)
        eruby.result(:codes => codes)
      end

      def self.exceptions
        @config ||= YAML.load_file('overrides.yml')
      end

      def self.recurse_merge(a,b)
        a.merge(b) do |_,x,y|
          (x.is_a?(Hash) && y.is_a?(Hash)) ? recurse_merge(x,y) : y
        end
      end
    end # UpdateCodes
  end # Task
end # IsoCountryCodes
