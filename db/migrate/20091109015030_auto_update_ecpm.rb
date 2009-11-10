class AutoUpdateEcpm < ActiveRecord::Migration
  def self.up
	add_column :tags, :auto_update_ecpm, :boolean, :default => true
  end

  def self.down
	remove_column :tags, :auto_update_ecpm, :boolean
  end
end
