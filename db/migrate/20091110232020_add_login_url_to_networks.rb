class AddLoginUrlToNetworks < ActiveRecord::Migration
  def self.up
    add_column :networks, :login_url, :string
  end

  def self.down
    remove_column :networks, :login_url
  end
end
