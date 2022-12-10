class IsoCountryCodes # :nodoc:
  class UnknownCodeError < StandardError; end

  class << self

    def for_select(*args)
      Code.for_select(*args)
    end

    def all
      Code.all
    end

    DEFAULT_FALLBACK = lambda { |error| raise UnknownCodeError, error }

    def find(code, &fallback)
      fallback ||= DEFAULT_FALLBACK
      code     = code.to_s.upcase
      instance = nil

      if code.match(/^\d{2}$/)
        code = "0#{code}" # Make numeric codes three digits
      end

      if code.match(/^\d{3}$/)
        instance = all.find { |c| c.numeric == code }
      elsif code.match(/^[A-Z]{2}$/)
        instance = all.find { |c| c.alpha2 == code }
      elsif code.match(/^[A-Z]{3}$/)
        instance = all.find { |c| c.alpha3 == code }
      end

      return fallback.call "No ISO 3166-1 code could be found for '#{code}'." if instance.nil?

      instance
    end

    def search_by_name(str, &fallback)
      fallback ||= DEFAULT_FALLBACK

      instances = all.select { |c| c.name.to_s.upcase == str.to_s.upcase }
      instances = all.select { |c| c.name.to_s.match(/^#{Regexp.escape(str)}/i) } if instances.empty?
      instances = all.select { |c| c.name.to_s.match(/#{Regexp.escape(str)}/i) } if instances.empty?
      instances = all.select { |c| word_set(c.name) == word_set(str) } if instances.empty?

      return fallback.call "No ISO 3166-1 codes could be found searching with name '#{str}'." if instances.empty?

      instances
    end

    def search_by_calling_code(code, &fallback)
      fallback ||= DEFAULT_FALLBACK

      code = "+#{code.to_i}" # Normalize code
      instances = all.select { |c| c.calling == code }

      return fallback.call "No ISO 3166-1 codes could be found searching with calling code '#{code}'." if instances.empty?

      instances
    end

    def search_by_calling(code, &fallback) # Alias of search_by_calling_code
      search_by_calling_code code, &fallback
    end

    def search_by_currency(code, &fallback)
      fallback ||= DEFAULT_FALLBACK

      code = code.to_s.upcase
      instances = all.select { |c|
        c.currencies.select { |currency|
          currency != code
        }.empty?
      }

      return fallback.call "No ISO 3166-1 codes could be found searching with currency '#{code}'." if instances.empty?

      instances
    end

    def search_by_iban(code, &fallback)
      fallback ||= DEFAULT_FALLBACK

      code = code.to_s.upcase
      instances = all.select { |c| c.iban == code }

      return fallback.call "No ISO 3166-1 codes could be found searching with IBAN '#{code}'." if instances.empty?

      instances
    end

    private
    def word_set(str)
      str.to_s.upcase.split(/\W/).reject(&:empty?).to_set
    end
  end
end
