= iso_country_codes
{<img src="https://travis-ci.org/alexrabarts/iso_country_codes.svg" alt="Build Status" />}[https://travis-ci.org/alexrabarts/iso_country_codes]

== DESCRIPTION:

Provides ISO codes, names and currencies for countries.

== FEATURES:

* Find by alpha-2, alpha-3 or numeric codes
* Search by name, currency code or calling/dialing code

== SYNOPSIS:

  # Finding an ISO code returns the country name and other code formats
  code = IsoCountryCodes.find('gb')
  code.name      # => "United Kingdom of Great Britain and Northern Ireland"
  code.numeric   # => "826"
  code.alpha2    # => "GB"
  code.alpha3    # => "GBR"
  code.calling   # => "+44"
  code.continent # => "EU"
  code.iban      # => "GB"

  # Codes can be found via numeric, alpha-2 or alpha-3 format
  IsoCountryCodes.find(36)
  IsoCountryCodes.find('au')
  IsoCountryCodes.find('aus')

  # Codes can also be returned by searching country name, currency, calling/dialing code or IBAN
  IsoCountryCodes.search_by_name('australia')
  IsoCountryCodes.search_by_currency('aud')
  IsoCountryCodes.search_by_calling_code('+61')
  IsoCountryCodes.search_by_iban('gb')

  # Fetch a country's local currency
  IsoCountryCodes.find('aus').currency # => "AUD"

  # Output an Array of countries and their codes for use form helper methods
  IsoCountryCodes.for_select # => Array

== INSTALL:

  gem install iso_country_codes

== DATA SOURCE:

IsoCountryCodes pulls its data from the Wikipedia ISO 3166-1 tables
(https://en.wikipedia.org/wiki/ISO_3166-1), combined with a small number of
overrides contained in the `overrides.yml` file. For example, the country name
of TWN is overridden to "Taiwan" from "Taiwan, Province of China", to make it
less politicised.

The format of the `overrides.yml` file is the 3-letter alpha country
code as the key, and the fields one wants to override as follows:

  "TWN":
    :name: "Taiwan"

== LICENSE:

(The MIT License)

Copyright (c) 2008 Stateless Systems (http://statelesssystems.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
