class CreateActsAsChangelogable < ActiveRecord::Migration
  def self.up
    create_table :changelogs do |t|
      t.integer :record_id
      t.string :record_type
      t.integer :user_id
      t.string :operation
      t.text :diff
      t.string :description
      t.timestamps
    end

    add_index :changelogs, :record_id
    add_index :changelogs, :user_id

    create_table :commits do |t|
      t.timestamps
    end

    create_table :changelogs_commits do |t|
      t.integer :changelog_id
      t.integer :commit_id
      t.timestamps
    end

    add_index :changelogs_commits, :changelog_id
    add_index :changelogs_commits, :commit_id
  end

  def self.down
    drop_table :changelogs
    drop_table :commits
    drop_table :changelogs_commits
  end
end
