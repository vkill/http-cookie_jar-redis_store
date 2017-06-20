require "spec_helper"

RSpec.describe HTTP::CookieJar::RedisStore do
  it "has a version number" do
    expect(HTTP::CookieJar::RedisStore::VERSION).not_to be nil
  end
end
