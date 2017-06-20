require "http/cookie"
require "http/cookie_jar/hash_store"

module HTTP
  class CookieJar
    class RedisStore < AbstractStore
      VERSION = "0.1.0"
    end
  end
end
