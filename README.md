# Gman Gem

[![Build Status](https://travis-ci.org/benbalter/gman.png)](https://travis-ci.org/benbalter/gman) [![Gem Version](https://badge.fury.io/rb/gman.png)](http://badge.fury.io/rb/gman)

A ruby gem to check if the owner of a given email address or website is working for THE MAN (a.k.a verifies government domains). It does this by leveraging the power of the [Public Suffix List](http://publicsuffix.org/), and the associated [Ruby Gem](https://github.com/weppos/publicsuffix-ruby).

You could theoretically [use regex](https://gist.github.com/benbalter/6147066), but either you'll a bunch of false positives, or your regex will be insanely complicated. `gov.uk`, may be valid, for example, but `gov.fr` is not (it's `gouv.fr`, for what it's worth).

The solution? Use Public Suffix to verify that it's a valid public domain, then maintain [a crowd-sourced sub-list of known global government and military domains](https://github.com/benbalter/gman/blob/master/lib/domains.txt). It should cover all US and international, government and military domains for both email and website verification.

See a domains that's missing or one that shouldn't be there? [We'd love you to contribute](CONTRIBUTING.md).

## Installation

Gman is a Ruby gem, so you'll need a little Ruby-fu to get it working. Simply

`gem install gman`

Or add this to your `Gemfile` before doing a `bundle install`:

`gem 'gman'`

## Usage

### Verify email addresses

```ruby
Gman.valid? "foo@bar.gov" #true
Gman.valid? "foo@bar.com" #false
```

### Verify domain

```ruby
Gman.valid? "http://foo.bar.gov" #true
Gman.valid? "foo.bar.gov" #true
Gman.valid? "foo.gov" #true
Gman.valid? "foo.biz" #false
```

### Get a domain name from an arbitrary domainy string

```ruby
Gman.get_domain "http://foo.bar.gov" # foo.bar.gov
Gman.get_domain "foo@bar.gov" # bar.gov
Gman.get_domain "foo.bar.gov" # foo.bar.gov
Gman.get_domain "asdf@asdf" # nil (no domain within the string)
```

## Contributing

Contributions welcome! Please see [the contribution guidelines](CONTRIBUTING.md) for code contributions or for details on how to add, update, or delete government domains.

## Credits

Heavily inspired by [swot](https://github.com/leereilly/swot). Thanks @leereilly!
