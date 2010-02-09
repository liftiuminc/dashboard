class AddReportingUrlToNetworks < ActiveRecord::Migration
  def self.up
    add_column :networks, :reporting_url, :string
  end

  def self.down
    remove_column :networks, :reporting_url
  end
end
