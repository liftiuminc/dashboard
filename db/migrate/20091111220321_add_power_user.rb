class AddPowerUser < ActiveRecord::Migration
  def self.up
    add_column :users, :power_user, :boolean, :default => false
  end

  def self.down
    remove_column :users, :power_user
  end
end
