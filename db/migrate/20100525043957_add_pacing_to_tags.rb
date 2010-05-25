class AddPacingToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :pacing, :float, {:precision => 3, :scale => 2 }
  end

  def self.down
    add_column :tags, :pacing
  end
end
