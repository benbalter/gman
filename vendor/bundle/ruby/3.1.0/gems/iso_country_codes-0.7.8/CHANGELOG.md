## 0.7.8

* Add (internal) override mechanism, and call TWN "Taiwan". (see #44)

## 0.7.7

* Updated the main currency for Lithuania from `LTL` to `EUR` (see #43)
* Updated the short name for Czech Reuplic to `Czechia` (see #42)

## 0.7.6

* Updated the main currency for Slovakia from `SKK` to `EUR` (see #41)
* Fixed a warning related to `Code#iban` (see #39)

## 0.7.5

* Improved `search_by_name` to handle names with commas and parentheses (see #37)

## 0.7.4

* Fixed calling code for Monaco

## 0.7.3

* Fixed country code for Guernsey IBAN entry. Also removes `nil` entry from
  `IsoCountryCodes::Code.all` and `IsoCountryCodes::Code.for_select` methods.

## 0.7.2 - 2015-09-17

* Fixed RegExp error in `search_by_name` (see #21)
* Moved Cyprus from Asia to Europe
* Added IBAN codes for British Crown Dependencies

## 0.7.1 - 2015-05-21

* Adds IsoCountryCodes.search_by_iban method to search by IBAN code

## 0.7.0 - 2015-05-21

* Adds ISO 13616-1 IBAN codes
* Updated with the latest data from Wikipedia

## 0.6.1 - 2014-11-08

* Allows continents to be accessed in a class instance

## 0.6.0 - 2014-10-23

* Added ability to raise custom fallbacks and return default values

## 0.5.0 - 2014-10-13

* Added continent codes

## 0.4.4 - 2014-07-23

* Corrected Korean currency codes (fixes #13)

## 0.4.3 - 2014-06-24

* Latvian LAT replaced with the Euro (fixes #10)
* Updated with the latest data from Wikipedia (fixes #12)

## 0.4.2 - 2013-09-17

* Fixed a problem with IsoCountryCodes.search_by_name when the result is an exact match

## 0.4.1 - 2013-04-03

* Fixed a problem with IsoCountryCodes.search_by_name when an exception is thrown
* Remvoed Jeweller dependency in development

## 0.4.0 - 2013-01-29

* Added country calling codes, which may be accessed with the `calling` instance method
* Added `search_by_name`, `search_by_currency` and `search_by_calling_code` methods
* `:fuzzy` option on `find` is deprecated (use the `search_by_name` method instead)

## 0.3.1 - 2013-01-28

* Updated with the latest data from Wikipedia

## 0.3.0 - 2012-03-13

* Added IsoCountryCodes.for_select convenience method
* Updated with the latest country names from Wikipedia

## 0.2.3 - 2011-10-27

* Updated with the latest data from Wikipedia

## 0.2.2 - 2009-08-07

* Added Ruby 1.9 UTF-8 encoding header
* Updated with the latest country names from Wikipedia

## 0.2.1 - 2008-11-25

* All Ruby warnings resolved

## 0.2.0 - 2008-11-24

* Currency codes added

## 0.1.2 - 2008-11-24

* Inexact strings can now be used to search for country names

## 0.1.1 - 2008-11-21

* Each country now represented by a single class instead of one for each code

## 0.1.0 - 2008-11-20

* Initial release
