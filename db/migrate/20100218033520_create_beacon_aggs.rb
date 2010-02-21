class CreateBeaconAggs < ActiveRecord::Migration
  def self.up
    execute "CREATE TABLE IF NOT EXISTS `beacon_agg` (
  `id` int(11) NOT NULL auto_increment,
  `hour` datetime default NULL,
  `tagid` int(11) default NULL,
  `previous_attempts` int(11) default NULL,
  `country` varchar(6) default NULL,
  `loads` int(11) default NULL,
  `rejects` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `beacon_hour_tag_idx` (`hour`,`tagid`),
  KEY `beacon_tag_idx` (`tagid`)
) ENGINE=MyISAM AUTO_INCREMENT=726040 DEFAULT CHARSET=utf8"
    #    create_table :beacon_aggs do |t|
    #      t.datetime :hour
    #      t.integer :previous_attempts
    #      t.string :country
    #      t.integer :loads
    #      t.timestamps
  end
  
  def self.down
  end
end
