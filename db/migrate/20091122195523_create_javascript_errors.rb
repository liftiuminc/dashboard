class CreateJavascriptErrors < ActiveRecord::Migration
  def self.up
    create_table :javascript_errors do |t|
      t.datetime :created_at
      t.references :publisher
      t.references :tag
      t.string :error_type
      t.string :language
      t.string :browser
      t.string :ip
      t.string :message
    end

    add_index :javascript_errors, :publisher_id
    add_index :javascript_errors, :tag_id
    add_index :javascript_errors, :created_at
  end
  
  def self.down
    drop_table :javascript_errors
  end
end
