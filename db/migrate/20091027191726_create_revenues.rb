class CreateRevenues < ActiveRecord::Migration
  def self.up
    create_table :revenues do |t|
      t.references  :tag
      t.references  :user
      t.integer     :attempts
      t.integer     :rejects
      t.integer     :clicks
      t.decimal     :revenue,   { :scale => 6, :precision => 9 }
      t.decimal     :ecpm,      { :scale => 6, :precision => 9 }
      t.date        :day
      t.timestamps
    end
  end
  
  def self.down
    drop_table :revenues
  end
end
