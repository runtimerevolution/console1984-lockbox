# Console1984::Lockbox

This gem has the purpose to add Lockbox encrypted methods into a protected state, provided by Console1984.

Whenever an environment(production) is considered protected, all encryptions(Lockbox|Activerecord) remain the same, action are logged. The console user is able to change into a unprotected mode and access the encrypted data. 

See more usage in [Console1984](https://github.com/basecamp/console1984)

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'console1984-lockbox'
```

And then execute:

    $ bundle install

Follow Console1984 [Installation](https://github.com/basecamp/console1984#installation)

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/runtimerevolution/console1984-lockbox.

