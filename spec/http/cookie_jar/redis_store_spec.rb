require "spec_helper"

RSpec.describe HTTP::CookieJar::RedisStore do
  it "has a version number" do
    expect(HTTP::CookieJar::RedisStore::VERSION).not_to be nil
  end

  it "jar's store is a RedisStore" do
    app_id = "HTTPCookieJar:Example:"
    jar = HTTP::CookieJar.new(store: :redis, redis_conn: Redis.new, app_id: app_id)

    expect(jar).to be_a HTTP::CookieJar
    expect(jar.store).to be_a HTTP::CookieJar::RedisStore
  end

end
