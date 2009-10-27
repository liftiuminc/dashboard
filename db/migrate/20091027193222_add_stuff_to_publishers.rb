class AddStuffToPublishers < ActiveRecord::Migration
  def self.up
	add_column :publishers, :privacy_policy, :boolean
	add_column :publishers, :site_description, :text
	add_column :publishers, :site_keywords, :string
  end

  def self.down
	remove_column :publishers, :privacy_policy
	remove_column :publishers, :site_description
	remove_column :publishers, :site_keywords
  end
end
