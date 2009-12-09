class ChangeCommentsToText < ActiveRecord::Migration
  def self.up
       # why on earth this was a varchar(255) is beyond me
       change_column :comments, :comment, :text
  end

  def self.down
       change_column :comments, :comment, :string
  end
end
