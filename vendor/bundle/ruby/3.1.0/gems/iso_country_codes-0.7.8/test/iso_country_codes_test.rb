require 'test/unit'
require 'iso_country_codes'

class TestIsoCountryCodes < Test::Unit::TestCase
  def test_find_with_numeric_as_two_digit_string
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find('36')
  end

  def test_find_with_numeric_as_three_digit_string
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find('036')
  end

  def test_find_with_numeric_as_integer
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find(36)
  end

  def test_find_with_lowercase_alpha2
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find('au')
  end

  def test_find_with_uppercase_alpha2
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find('AU')
  end

  def test_find_with_unknown_alpha2_code_and_raise_exception
    assert_raise IsoCountryCodes::UnknownCodeError do
      IsoCountryCodes.find('xx')
    end
  end

  def test_find_with_unknown_alpha2_code_and_raise_custom_exception
    assert_raise ArgumentError do
      IsoCountryCodes.find('xx') { |error| raise ArgumentError }
    end
  end

  def test_find_with_unknown_alpha2_code_and_return_custom_value
    assert_equal IsoCountryCodes.find('xx') { IsoCountryCodes::Code::AUS.instance },
      IsoCountryCodes::Code::AUS.instance
  end

  def test_find_with_lowercase_alpha3
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find('aus')
  end

  def test_find_with_uppercase_alpha3
    assert_equal IsoCountryCodes::Code::AUS.instance, IsoCountryCodes.find('AUS')
  end

  def test_search_with_lowercase_name
    assert_equal [IsoCountryCodes::Code::AUS.instance], IsoCountryCodes.search_by_name('australia')
  end

  def test_search_with_uppercase_name
    assert_equal [IsoCountryCodes::Code::AUS.instance], IsoCountryCodes.search_by_name('AUSTRALIA')
  end

  def test_search_with_mixed_case_name
    assert_equal [IsoCountryCodes::Code::AUS.instance], IsoCountryCodes.search_by_name('Australia')
  end

  def test_search_comma_separated_name
    assert_equal [IsoCountryCodes::Code::PSE.instance], IsoCountryCodes.search_by_name('State of Palestine')
  end

  def test_search_parenthetical_name
    assert_equal [IsoCountryCodes::Code::KOR.instance], IsoCountryCodes.search_by_name('Republic of Korea')
  end

  def test_search_by_name_returning_many_results_starting_wth_the_search_string
    assert_equal([
      IsoCountryCodes::Code::ARE.instance,
      IsoCountryCodes::Code::GBR.instance,
      IsoCountryCodes::Code::USA.instance,
      IsoCountryCodes::Code::UMI.instance
    ], IsoCountryCodes.search_by_name('united'))
  end

  def test_search_by_name_returning_many_results_not_starting_with_the_search_string
    assert_equal([
      IsoCountryCodes::Code::COD.instance,
      IsoCountryCodes::Code::PRK.instance,
      IsoCountryCodes::Code::LAO.instance
    ], IsoCountryCodes.search_by_name('democratic'))
  end

  def test_search_by_name_unknown_country_and_raise_exception
    assert_raise IsoCountryCodes::UnknownCodeError do
      IsoCountryCodes.search_by_name('unknown country')
    end
  end

  def test_search_by_name_unknown_country_and_raise_custom_exception
    assert_raise ArgumentError do
      IsoCountryCodes.search_by_name('unknown country') {|error| raise ArgumentError }
    end
  end

  def test_search_by_name_unknown_country_and_return_custom_value
    assert_equal IsoCountryCodes.search_by_name('unknown country') {[]}, []
  end

  def test_search_by_name_does_not_raise_regexp_error
    assert_nothing_raised do
      IsoCountryCodes.search_by_name('+ab'){[]}
    end
  end

  def test_search_by_name_exact_match
    assert_equal(
      [IsoCountryCodes::Code::CCK.instance],
      IsoCountryCodes.search_by_name('Cocos (Keeling) Islands')
    )
  end

  def test_search_by_currency_lowercase
    assert_equal([
      IsoCountryCodes::Code::AUS.instance,
      IsoCountryCodes::Code::CXR.instance,
      IsoCountryCodes::Code::CCK.instance,
      IsoCountryCodes::Code::HMD.instance,
      IsoCountryCodes::Code::KIR.instance,
      IsoCountryCodes::Code::NRU.instance,
      IsoCountryCodes::Code::NFK.instance
    ], IsoCountryCodes.search_by_currency('aud'))
  end

  def test_search_by_currency_uppercase
    assert_equal([
      IsoCountryCodes::Code::AUS.instance,
      IsoCountryCodes::Code::CXR.instance,
      IsoCountryCodes::Code::CCK.instance,
      IsoCountryCodes::Code::HMD.instance,
      IsoCountryCodes::Code::KIR.instance,
      IsoCountryCodes::Code::NRU.instance,
      IsoCountryCodes::Code::NFK.instance
    ], IsoCountryCodes.search_by_currency('AUD'))
  end

  def test_search_by_currency_invalid_value_and_raise_exception
    assert_raise IsoCountryCodes::UnknownCodeError do
      IsoCountryCodes.search_by_currency('USS')
    end
  end

  def test_search_by_currency_invalid_value_and_raise_custom_exception
    assert_raise ArgumentError do
      IsoCountryCodes.search_by_currency('USS') { |error| raise ArgumentError }
    end
  end

  def test_search_by_currency_invalid_value_and_return_custom_value
    assert_equal IsoCountryCodes.search_by_currency('USS') {[]}, []
  end

  def test_search_by_calling_code
    assert_equal [IsoCountryCodes::Code::ZAF.instance], IsoCountryCodes.search_by_calling_code('+27')
    assert_equal([
      IsoCountryCodes::Code::AUS.instance,
      IsoCountryCodes::Code::CXR.instance,
      IsoCountryCodes::Code::HMD.instance
    ], IsoCountryCodes.search_by_calling_code('+61'))
  end

  def test_search_by_calling_code_invalid_value_and_raise_exception
    assert_raise IsoCountryCodes::UnknownCodeError do
      IsoCountryCodes.search_by_calling_code('00')
    end
  end

  def test_search_by_calling_code_invalid_value_and_raise_custom_exception
    assert_raise ArgumentError do
      IsoCountryCodes.search_by_calling_code('00'){ |error| raise ArgumentError }
    end
  end

  def test_search_by_calling_code_invalid_value_and_return_custom_value
    assert_equal IsoCountryCodes.search_by_calling_code('00') {[]}, []
  end

  def test_search_by_iban_lowercase
    assert_equal [IsoCountryCodes::Code::BIH.instance], IsoCountryCodes.search_by_iban('ba')
  end

  def test_search_by_iban_uppercase
    assert_equal [IsoCountryCodes::Code::BIH.instance], IsoCountryCodes.search_by_iban('BA')
  end

  def test_search_by_iban_invalid_value_and_raise_exception
    assert_raise IsoCountryCodes::UnknownCodeError do
        IsoCountryCodes.search_by_iban('xx')
    end
  end

  def test_search_by_iban_invalid_value_and_raise_custom_exception
    assert_raise ArgumentError do
        IsoCountryCodes.search_by_iban('xx'){ |error| raise ArgumentError }
    end
  end

  def test_search_by_iban_invalid_value_and_return_custom_value
    assert_equal IsoCountryCodes.search_by_iban('xx') {[]}, []
  end

  def test_get_main_currency
    assert_equal 'AUD', IsoCountryCodes.find('AUS').main_currency
  end

  def test_currency_alias_method
    code = IsoCountryCodes::Code::AUS.instance
    assert_equal code.main_currency, code.currency
  end

  def test_get_multiple_currencies
    assert_equal IsoCountryCodes.find('ATA').currencies, %w{AUD GBP}
    assert_equal IsoCountryCodes.find('AUS').currencies, %w{AUD}
  end

  def test_get_numeric
     assert_equal '036', IsoCountryCodes::Code::AUS.numeric
     assert_equal '036', IsoCountryCodes::Code::AUS.instance.numeric
  end

  def test_get_alpha2
    assert_equal 'AU', IsoCountryCodes::Code::AUS.alpha2
    assert_equal 'AU', IsoCountryCodes::Code::AUS.instance.alpha2
  end

  def test_get_alpha3
    assert_equal 'AUS', IsoCountryCodes::Code::AUS.alpha3
    assert_equal 'AUS', IsoCountryCodes::Code::AUS.instance.alpha3
  end

  def test_get_calling
    assert_equal '+61', IsoCountryCodes::Code::AUS.calling
    assert_equal '+61', IsoCountryCodes::Code::AUS.instance.calling
  end

  def test_get_iban
    assert_equal 'FR', IsoCountryCodes::Code::FRA.iban
    assert_equal 'FR', IsoCountryCodes::Code::FRA.instance.iban
  end

  def test_get_iban_for_non_iban_country
    assert_equal nil, IsoCountryCodes::Code::USA.iban
    assert_equal nil, IsoCountryCodes::Code::USA.instance.iban
  end

  def test_get_calling_code_alias
    code = IsoCountryCodes::Code::AUS.instance
    assert_equal code.calling, code.calling_code
  end

  def test_get_continent
    assert_equal 'OC', IsoCountryCodes::Code::AUS.continent
    assert_equal 'NA', IsoCountryCodes::Code::USA.instance.continent
  end

  def test_get_name
    assert_equal 'Australia', IsoCountryCodes::Code::AUS.name
    assert_equal 'Australia', IsoCountryCodes::Code::AUS.instance.name
  end

  def test_for_select
    assert       IsoCountryCodes::Code.for_select.is_a?(Array)
    assert_equal IsoCountryCodes::Code.for_select.length, IsoCountryCodes::Code.all.length
  end

  def test_all
    assert          IsoCountryCodes::Code.all.is_a?(Array)
    refute_includes IsoCountryCodes::Code.all.map(&:name), nil
  end

  def test_for_select_value_attribute
    assert_equal IsoCountryCodes::Code.for_select(:alpha3)[0][1].length, 3
  end

  def test_unknown_iso_code
    assert_raises IsoCountryCodes::UnknownCodeError do
      IsoCountryCodes.find('FOO')
    end
  end

  def test_unknown_iso_code_and_return_custom_value
    assert_equal IsoCountryCodes.find('FOO') { [] }, []
  end

  def test_unknown_iso_code_and_raise_custom_error
    assert_raise ArgumentError do
      IsoCountryCodes.find('FOO') { |error| raise ArgumentError }
    end
  end
end
