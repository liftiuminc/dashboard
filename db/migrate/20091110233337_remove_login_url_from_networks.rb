class RemoveLoginUrlFromNetworks < ActiveRecord::Migration
  def self.up
    remove_column :networks, :login_url
  end

  def self.down
    add_column :networks, :login_url, :text
  end
end
