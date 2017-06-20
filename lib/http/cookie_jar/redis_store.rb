require "http/cookie_jar/redis_store_version"

require "http/cookie"
require "http/cookie_jar/hash_store"

module HTTP
  class CookieJar
    class RedisStore < AbstractStore
      VERSION = ::HTTP::CookieJar::RedisStoreVERSION

      def default_options
        {
          :gc_threshold => HTTP::Cookie::MAX_COOKIES_TOTAL / 20,
          :app_id => "",
        }
      end

      def initialize(options = nil)
        super

        @redis_conn = options[:redis_conn] or raise ArgumentError, ':redis_conn option is missing'

        if @app_id.to_s == ''
          raise "please set app_id"
        end

        @sjar = HTTP::CookieJar::HashStore.new

        @gc_index = 0
      end

      def initialize_copy(other)
        raise TypeError, "can't clone %s" % self.class
      end

      attr_reader :redis_conn

      def redis_call(*args)
        if @redis_conn.is_a?(ConnectionPool)
          @redis_conn.with{|conn| conn.call(args) }
        else
          @redis_conn.call(args)
        end
      end

      def db_add(cookie)
        v = {
          :name => cookie.name,
          :domain => cookie.dot_domain,
          :path => cookie.path,
          :domain_base => cookie.domain_name.domain || cookie.domain,
          :value => cookie.value,
          :expires_at => cookie.expires_at.to_i,
          :created_at => cookie.created_at.to_i,
          :accessed_at => cookie.accessed_at.to_i,
          :secure => cookie.secure? ? 1 : 0,
          :httponly => cookie.httponly? ? 1 : 0,
        }
        k = v.select{|key, val| [:name, :domain, :path].include?(key)}.values.join('|')

        redis_call(:hset, "#{@app_id}", k, v.to_json)

        cleanup if (@gc_index += 1) >= @gc_threshold

        self
      end

      def db_delete(cookie)
        v = {
          :name => cookie.name,
          :domain => cookie.dot_domain,
          :path => cookie.path,
        }
        k = v.select{|key, val| [:name, :domain, :path].include?(key)}.values.join('|')

        redis_call(:hdel, "#{@app_id}", k)

        self
      end

      def db_list(uri=nil)
        now = Time.now

        cookies = redis_call(:hgetall, "#{@app_id}")
        cookies ||= []

        cookies = cookies.each_slice(2).to_h
        cookies = cookies.map{|k, v| [k, JSON.parse(v)]}.to_h

        if uri
          thost = DomainName.new(uri.host)
          tpath = uri.path

          cookies = cookies.select do |k, v|
            v['domain_base'] == (thost.domain || thost.hostname) &&
              v['expires_at'] > now.to_i
          end
        else
          cookies = cookies.select do |k, v|
            v['expires_at'] > now.to_i
          end
        end

        cookies.values
      end

      def db_clear
        redis_call(:del, "#{@app_id}")
      end

      public

      def add(cookie)
        if cookie.session?
          @sjar.add(cookie)
          db_delete(cookie)
        else
          @sjar.delete(cookie)
          db_add(cookie)
        end
      end

      def delete(cookie)
        @sjar.delete(cookie)
        db_delete(cookie)
      end

      def each(uri = nil, &block) # :yield: cookie
        now = Time.now
        if uri
          cookie_hashes = db_list(uri)
          cookie_hashes.each do |cookie_h|
            if secure = cookie_h['secure'] != 0
              next unless URI::HTTPS === uri
            end

            cookie = HTTP::Cookie.new({}.tap { |attrs|
              attrs[:name]        = cookie_h['name']
              attrs[:value]       = cookie_h['value']
              attrs[:domain]      = cookie_h['domain']
              attrs[:path]        = cookie_h['path']
              attrs[:expires_at]  = Time.at(cookie_h['expires_at'])
              attrs[:accessed_at] = Time.at(cookie_h['accessed_at'] || 0)
              attrs[:created_at]  = Time.at(cookie_h['created_at'] || 0)
              attrs[:secure]      = secure
              attrs[:httponly]    = cookie_h['httponly'] != 0
            })

            if cookie.valid_for_uri?(uri)
              cookie.accessed_at = now
              # TODO update redis accessed_at
              yield cookie
            end
          end

          @sjar.each(uri, &block)
        else
          cookie_hashes = db_list()
          cookie_hashes.each do |cookie_h|
            secure = cookie_h['secure']

            cookie = HTTP::Cookie.new({}.tap { |attrs|
              attrs[:name]        = cookie_h['name']
              attrs[:value]       = cookie_h['value']
              attrs[:domain]      = cookie_h['domain']
              attrs[:path]        = cookie_h['path']
              attrs[:expires_at]  = Time.at(cookie_h['expires_at'])
              attrs[:accessed_at] = Time.at(cookie_h['accessed_at'] || 0)
              attrs[:created_at]  = Time.at(cookie_h['created_at'] || 0)
              attrs[:secure]      = secure
              attrs[:httponly]    = cookie_h['httponly'] != 0
            })

            yield cookie
          end

          @sjar.each(&block)
        end
        self
      end

      def clear
        db_clear

        @sjar.clear

        self
      end

      def cleanup(session = false)
        synchronize {
          break if @gc_index == 0

          # TODO

          @gc_index = 0
        }

        self
      end
    end
  end
end
