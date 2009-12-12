class ChangeDefaultForThreshold < ActiveRecord::Migration
  def self.up
     change_column_default(:networks, :supports_threshold, false)
  end

  def self.down
     change_column_default(:networks, :supports_threshold, true)
  end
end
