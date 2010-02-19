class BuildGoogleStats < ActiveRecord::Migration
  def self.up
	execute "CREATE TABLE IF NOT EXISTS `google_tag_stats` (
  `tag_id` int(11) NOT NULL,
  `stat_date` date NOT NULL default '0000-00-00',
  `views` int(11) unsigned NOT NULL,
  PRIMARY KEY  (`tag_id`,`stat_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci"
  end

  def self.down
  end
end
