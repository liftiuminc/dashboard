require 'test_helper'

class EventRecorderTest < ActiveSupport::TestCase
  context "class methods" do
    setup do
      @event_array = ['Ad Delivered', 'AdBrite', 'US']
      now = Time.parse("2009/12/01 20:30")
      Time.stubs(:now).returns(now)
    end

    context "#serialize_key" do
      should "build the key based off of the elements provided and html escape the name" do
        assert_match "Ad%20Delivered:AdBrite:US", EventRecorder.serialize_key(@event_array)
      end

      should "append YYYYMMDD_HH by default or if 'hour' is specified in the rotation" do
        assert_equal "Ad%20Delivered:AdBrite:US:20091201_20", EventRecorder.serialize_key(@event_array)
        assert_equal "Ad%20Delivered:AdBrite:US:20091201_20", EventRecorder.serialize_key(@event_array, "hour")
      end

      should "append YYYYMMDD_HHMM if 'minute' is specified in the rotation" do
        assert_equal "Ad%20Delivered:AdBrite:US:20091201_203000", EventRecorder.serialize_key(@event_array, "minute")
      end

      should "append YYYYMMDD if 'day' is specified in the rotation" do
        assert_equal "Ad%20Delivered:AdBrite:US:20091201", EventRecorder.serialize_key(@event_array, "day")
      end
    end

    context "#unserialize_key" do
      should "break the key into it's interesting parts" do
        results = { :events => @event_array, :time => "20091201_203000", :rotation => "minute" }
        assert_equal results, EventRecorder.unserialize_key("Ad%20Delivered:AdBrite:US:20091201_203000")
      end

      context "get_rotation" do
        should "return 'minute' when the strlen of time is 15 characters" do
          results = { :events => @event_array, :time => "20091201_203000", :rotation => "minute" }
          assert_equal results, EventRecorder.unserialize_key("Ad%20Delivered:AdBrite:US:20091201_203000")
        end

        should "return 'hour' when the strlen of time is 11 characters" do
          results = { :events => @event_array, :time => "20091201_20", :rotation => "hour" }
          assert_equal results, EventRecorder.unserialize_key("Ad%20Delivered:AdBrite:US:20091201_20")
        end

        should "return 'day' when the strlen of time is 8 characters" do
          results = { :events => @event_array, :time => "20091201", :rotation => "day" }
          assert_equal results, EventRecorder.unserialize_key("Ad%20Delivered:AdBrite:US:20091201")
        end
      end
    end

    context "#read" do
      should "read an array of data from memcache" do
        key = EventRecorder.serialize_key(@event_array)
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:read).with(key, EventRecorder::MEMCACHE_READ_OPTIONS).returns(@event_array)
        assert @event_array, EventRecorder.read(key)
      end
    end

    context "#record" do
      setup do
        @key = EventRecorder.serialize_key(@event_array)
      end

      should "create the memcache key based off the given data, rotation (default 'hour') and timeout (default 86400) and increment the count" do
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).with(@key, 0, :expires_in => 86400).returns(true)
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:increment).with(@key, 1).returns(true)
        assert EventRecorder.record(@event_array)
      end

      should "not write the key if it already exists in memcache, just increment it" do
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:exist?).with(@key, EventRecorder::MEMCACHE_READ_OPTIONS).returns(true)
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).never
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:increment).with(@key, 1).returns(true)
        assert EventRecorder.record(@event_array)
      end

      should "return true on successful write, false if not" do
        ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).with(@key, 0, :expires_in => 86400).returns(false)
        assert !EventRecorder.record(@event_array)
      end

      context "timeout" do
        should "set the key lifetime to 360 when rotation = 'minute'" do
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:exist?).with(@key, EventRecorder::MEMCACHE_READ_OPTIONS).returns(false)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).with(@key, 0, :expires_in => 360).returns(true)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:increment).with(@key, 1).returns(true)
          assert EventRecorder.record(@event_array, "minute")
        end

        should "set the key lifetime to 86400 when rotation = 'hour'" do
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:exist?).with(@key, EventRecorder::MEMCACHE_READ_OPTIONS).returns(false)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).with(@key, 0, :expires_in => 86400).returns(true)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:increment).with(@key, 1).returns(true)
          assert EventRecorder.record(@event_array, "hour")
        end

        should "set the key lifetime to 604800 when rotation = 'day'" do
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:exist?).with(@key, EventRecorder::MEMCACHE_READ_OPTIONS).returns(false)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).with(@key, 0, :expires_in => 604800).returns(true)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:increment).with(@key, 1).returns(true)
          assert EventRecorder.record(@event_array, "day")
        end

        should "set the key lifetime to 300 when rotation is nil" do
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:exist?).with(@key, EventRecorder::MEMCACHE_READ_OPTIONS).returns(false)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:write).with(@key, 0, :expires_in => 300).returns(true)
          ActiveSupport::Cache::MemCacheStore.any_instance.expects(:increment).with(@key, 1).returns(true)
          assert EventRecorder.record(@event_array, nil)
        end
      end
    end

  end
end
