class Fillstatstables < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE IF NOT EXISTS fills_minute (tag_id int(11) NOT NULL, minute datetime, attempts int unsigned default 0, loads int unsigned default 0, rejects int unsigned default 0, PRIMARY KEY (tag_id, minute))"
    execute "CREATE TABLE IF NOT EXISTS fills_hour (tag_id int(11) NOT NULL, hour datetime, attempts int unsigned default 0, loads int unsigned default 0, rejects int unsigned default 0, PRIMARY KEY (tag_id, hour))"
    execute "CREATE TABLE IF NOT EXISTS fills_day (tag_id int(11) NOT NULL, day date, attempts int unsigned default 0, loads int unsigned default 0, rejects int unsigned default 0, PRIMARY KEY (tag_id, day))"
  end

  def self.down
    drop_table :fills_minute
    drop_table :fills_hour
    drop_table :fills_day
  end
end
