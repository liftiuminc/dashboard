class AddCategoryToPublishers < ActiveRecord::Migration
  def self.up
    add_column :publishers, :category, :string
  end

  def self.down
    remove_column :publishers, :category
  end
end
