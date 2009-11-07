class Publisher < ActiveRecord::Base
  acts_as_changelogable

  require 'uri'

  CATEGORIES = ["Auto","Creative","Education","Entertainment","Finance",
		"Gaming","Green","Humor","Lifestyle","Music","Philosophy",
		"Politics","Science","Sports","Technology","Toys","Travel"]

  has_many :users
  has_many :tags, :dependent => :destroy
  has_many :publisher_network_logins, :dependent => :destroy
  has_many :publisher_ad_formats, :dependent => :destroy
  has_many :ad_formats, :through => :publisher_ad_formats

  validates_uniqueness_of :site_name
  validates_presence_of :site_name
  validates_presence_of :site_url
  validates_format_of :xdm_iframe_path, :with => /^\/[^ ]+/, :allow_blank => true, :message => "must be a local path Ex. /liftium_iframe.html"
  validates_numericality_of :beacon_throttle, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1
  validates_inclusion_of :category, :in => CATEGORIES, :message => "must be one of: " + CATEGORIES.join(', '), :allow_blank => true
  validates_inclusion_of :privacy_policy, :in => [true, false], :allow_blank =>true


   ### make sure all urls start with http(s?). See FB 32
   def site_url=(url)

      ### this will catch any malformed uris
      if url.length > 0
         url = URI.parse( url =~ /^https?/i ? url : 'http://' + url ).to_s
      end

      write_attribute( :site_url, url )
   end

   def privacy_policy_s
      privacy_policy ? "Yes" : "No"
   end

end
