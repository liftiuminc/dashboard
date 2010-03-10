class AddMaxImpToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, "max_daily_impressions", :integer
  end

  def self.down
    remove_column :tags, "max_daily_impressions"
  end
end
