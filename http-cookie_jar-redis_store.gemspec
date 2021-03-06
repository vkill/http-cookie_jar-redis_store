# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "http/cookie_jar/redis_store_version"

Gem::Specification.new do |spec|
  spec.name          = "http-cookie_jar-redis_store"
  spec.version       = HTTP::CookieJar::RedisStoreVERSION
  spec.authors       = ["vkill"]
  spec.email         = ["vkill.net@gmail.com"]

  spec.summary       = %q{Redis store for http cookie_jar (https://github.com/sparklemotion/http-cookie)}
  spec.description   = %q{Redis store for http cookie_jar (https://github.com/sparklemotion/http-cookie)}
  spec.homepage      = "https://github.com/vkill/http-cookie_jar-redis_store"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "http-cookie",    "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency "redis", '~> 0'
end
