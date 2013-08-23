# Gman Gem

A ruby gem to check if the owner of a given email address or website is working for THE MAN (a.k.a verifies government domains).

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
