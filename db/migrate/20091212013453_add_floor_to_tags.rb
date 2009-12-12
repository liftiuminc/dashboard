class AddFloorToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :floor, :decimal, {:precision => 3, :scale => 2 }
  end

  def self.down
    remove_column :tags, :floor
  end
end
