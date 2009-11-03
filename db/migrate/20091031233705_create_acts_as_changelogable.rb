class CreateActsAsChangelogable < ActiveRecord::Migration
  def self.up
    create_table :acts_as_changelogs do |t|
      t.integer :record_id
      t.string :record_type
      t.integer :user_id
      t.string :operation
      t.text :diff
      t.string :description
      t.timestamps
    end
    add_index :acts_as_changelogs, :record_id
    add_index :acts_as_changelogs, :user_id
  end

  def self.down
    drop_table :acts_as_changelogs
  end
end
