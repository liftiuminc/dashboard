class AddUrlLineJavascriptErrors < ActiveRecord::Migration
  def self.up 
    add_column :javascript_errors, :url, :string
    add_column :javascript_errors, :line, :integer
  end

  def self.down
    remove_column :javascript_errors, :url
    remove_column :javascript_errors, :line
  end
end
