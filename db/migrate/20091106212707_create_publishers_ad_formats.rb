class CreatePublishersAdFormats < ActiveRecord::Migration
  def self.up
        create_table "publishers_ad_formats" do |t|
          t.references :publisher
          t.references :ad_format
        end
        add_index "publishers_ad_formats", :publisher_id
        add_index "publishers_ad_formats", :ad_format_id
  end

  def self.down
    drop_table :publishers_ad_formats
  end
end
