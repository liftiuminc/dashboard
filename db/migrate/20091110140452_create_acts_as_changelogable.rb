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

    create_table :acts_as_changelog_commits do |t|
      t.timestamps
    end

    create_table :acts_as_changelog_changelogs_commits do |t|
      t.integer :changelog_id
      t.integer :commit_id
      t.timestamps
    end

    add_index :acts_as_changelog_changelogs_commits, :changelog_id
    add_index :acts_as_changelog_changelogs_commits, :commit_id
  end

  def self.down
    drop_table :acts_as_changelogs
    drop_table :acts_as_changelog_commits
    drop_table :acts_as_changelog_changelogs_commits
  end
end
