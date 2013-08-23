# Gman Gem

A ruby gem to check if the owner of a given email address or website is working for THE MAN (a.k.a verifies government domains). It does this by leveraging the power of the [Public Suffix List](http://publicsuffix.org/), and the associated [Ruby Gem](https://github.com/weppos/publicsuffix-ruby).

You could theoretically [use regex](https://gist.github.com/benbalter/6147066), but either you'll a bunch of false positives, or your regex will be insanely complicated. `gov.uk`, may be valid, for example, but `gov.fr` is not (it's `gouv.fr`, for what it's worth).

The solution? Use Public Suffix to verify that it's a valid public domain, then maintain a crowd-soured sub list of known government and military domains. It should cover all US and international, government and military domains for both email and website verification.

## Installation

Gman is a Ruby gem, so you'll need a little Ruby-fu to get it working. Simply

`gem install gman`

Or add this to your `Gemfile` before doing a `bundle install`:

`gem 'gman'`

## Usage

### Verify email addresses

```ruby
Gman::is_government? "foo@bar.gov" #true
Gman::is_government? "foo@bar.com" #false
```
### Verify domain

```ruby
Gman::is_government? "http://foo.bar.gov" #true
Gman::is_government? "foo.bar.gov" #true
Gman::is_government? "foo.gov" #true
Gman::is_government? "foo.biz" #false
```

## Contributing

Contributions welcome! Please see [the contribution guidelines](contributing.md) for code contributions or for details on how to add, update, or delete government domains.

## Credits

Heavily inspired by [swot](https://github.com/leereilly/swot). Thanks @leereily!
