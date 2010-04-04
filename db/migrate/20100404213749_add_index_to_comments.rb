class AddIndexToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    remove_index :comments, [:commentable_id, :commentable_type]
  end
end
