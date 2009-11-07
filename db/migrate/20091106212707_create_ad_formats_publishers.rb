class CreateAdFormatsPublishers < ActiveRecord::Migration
  def self.up
        create_table "ad_formats_publishers" do |t|
          t.references :publisher
          t.references :ad_format
        end
        add_index "ad_formats_publishers", :publisher_id
        add_index "ad_formats_publishers", :ad_format_id
  end

  def self.down
    drop_table :ad_formats_publishers
  end
end
