class AddIndexToRevenues < ActiveRecord::Migration
  def self.up
    add_index :revenues, [:tag_id, :day], :unique => true
  end

  def self.down
    remove_index :revenues, [:tag_id, :day]
  end
end
