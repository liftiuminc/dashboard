class CreatePublisherAdFormats < ActiveRecord::Migration
  def self.up
        create_table "publisher_ad_formats" do |t|
          t.references :publisher
          t.references :ad_format
        end
        add_index "publisher_ad_formats", :publisher_id
        add_index "publisher_ad_formats", :ad_format_id
  end

  def self.down
    drop_table :publisher_ad_formats
  end
end
