require 'test_helper'

class EventRecorderTest < Test::Unit::TestCase
  context "with a real memcache server" do
    setup do
      config = YAML.load(File.open(EventRecorder::MEMCACHE_CONFIG_PATH, "r"))[RAILS_ENV]
      cache = ActiveSupport::Cache.lookup_store(:mem_cache_store, config["servers"])
      cache.clear
    end

    should "record an event into memcache and read the incremented value back" do
      assert EventRecorder.record(['Ad Delivered', 'AdBrite', 'US'])
      assert_equal 1, EventRecorder.read(EventRecorder.serialize_key(['Ad Delivered', 'AdBrite', 'US'])).to_i
    end
  end
end
