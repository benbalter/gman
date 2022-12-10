require 'singleton'

class IsoCountryCodes
  class Code
    include Singleton

    def name
      self.class.name
    end

    def numeric
      self.class.numeric
    end

    def alpha2
      self.class.alpha2
    end

    def alpha3
      self.class.alpha3
    end

    def calling
      self.class.calling
    end

    def calling_code
      self.class.calling_code
    end

    def continent
      self.class.continent
    end

    def main_currency
      self.class.main_currency
    end

    def currency
      self.class.currency
    end

    def currencies
      self.class.currencies
    end

    def iban
      self.class.iban
    end

    class << self
      attr_accessor :name, :numeric, :alpha2, :alpha3, :calling, :continent, :main_currency
      attr_writer :currencies, :iban
      alias_method :currency, :main_currency
      alias_method :calling_code, :calling

      @@codes = []
      def inherited(code) #:nodoc:
        super
        @@codes << code.instance if self == IsoCountryCodes::Code
      end

      def all
        @@codes.uniq
      end

      def for_select(type = :alpha2)
        all.map { |country| [country.name, country.send(type)] }
      end

      def currencies
        if defined? @currencies
          return @currencies
        else
          return [@main_currency]
        end
      end

      def iban
        # Return `nil` if the country doesn't use IBANs
        return @iban if defined? @iban
      end
    end
  end
end
