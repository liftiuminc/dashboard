class EventRecorder
  MEMCACHE_READ_OPTIONS = {:raw => true}
  MEMCACHE_CONFIG_PATH = File.join(File.dirname(__FILE__), '../../config/memcached.yml')

  class << self
    def read(key)
      get_cache.read(key, MEMCACHE_READ_OPTIONS)
    end

    def record(event, rotation = "hour", lifetime = nil)
      ensure_cache_key_exists(key = serialize_key(event), rotation, lifetime)
      get_cache.increment(key)
    end

    def serialize_key(event, rotation = "hour", time = nil)
      pieces = event.collect{ |element| URI.escape(element) } << get_time_floor(rotation, time || Time.now)
      pieces.join(":")
    end

    def unserialize_key(key)
      pieces = key.split(":")
      time = pieces.pop
      {:events => pieces.collect{ |element| URI.unescape(element) }, :time => time, :rotation => get_rotation(time)}
    end

    def get_events_by_type(event_type)
      cache_key_list.inject([]) do |arr, key|
        data = unserialize_key(key)
        arr = data if data[:events][0] == event_type
      end
    end

    private

    def cache_key_list
      #TODO - how to do this??
    end

    def ensure_cache_key_exists(key, rotation, lifetime)
      unless get_cache.exist?(key, MEMCACHE_READ_OPTIONS)
        result = get_cache.write(key, 0, :expires_in => lifetime || get_lifetime(rotation))
        return false unless result
      end
      true
    end

    def get_cache
      @@cache ||= begin
        config = YAML.load(File.open(MEMCACHE_CONFIG_PATH, "r"))[RAILS_ENV]
        ActiveSupport::Cache.lookup_store(:mem_cache_store, config["servers"])
      end
    end

    def get_lifetime(rotation)
      case
        when rotation == "minute" then 360
        when rotation == "hour"   then 86400
        when rotation == "day"    then 604800
        else                           300
      end
    end

    def get_rotation(time)
      case
        when time.length == 15 then "minute"
        when time.length == 11 then "hour"
        when time.length == 8  then "day"
      end
    end

    def get_time_floor(rotation, time)
      case
        when rotation == "hour"   then time.strftime("%Y%m%d_%H")
        when rotation == "minute" then time.strftime("%Y%m%d_%H%M00")
        when rotation == "day"    then time.strftime("%Y%m%d")
      end
    end
  end
end
