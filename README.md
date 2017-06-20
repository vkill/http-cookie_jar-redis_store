# HTTP::CookieJar::RedisStore

Redis store for [http cookie_jar](https://github.com/sparklemotion/http-cookie)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http-cookie_jar-redis_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install http-cookie_jar-redis_store

## Usage

```ruby
app_id = "HTTPCookieJar:Example:"
jar = HTTP::CookieJar.new(store: :redis, redis_conn: Redis.new, app_id: app_id)
jar.cookies
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vkill/http-cookie_jar-redis_store.
