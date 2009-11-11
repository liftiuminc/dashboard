class LiftiumNetworkLogins < ActiveRecord::Migration
  def self.up
    add_column :networks, :liftium_username, :string
    add_column :networks, :liftium_password, :string
  end

  def self.down
    remove_column :networks, :liftium_username
    remove_column :networks, :liftium_password
  end
end
