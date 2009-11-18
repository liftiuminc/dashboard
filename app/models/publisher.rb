class Publisher < ActiveRecord::Base
  acts_as_changelogable
  acts_as_commentable

  require 'uri'

  CATEGORIES = ["Auto","Creative","Education","Entertainment","Finance",
		"Gaming","Green","Humor","Lifestyle","Music","Philosophy",
		"Politics","Science","Sports","Technology","Toys","Travel"]

  has_many :users
  has_many :tags, :dependent => :destroy
  has_many :publisher_network_logins, :dependent => :destroy
  has_and_belongs_to_many :ad_formats

  validates_uniqueness_of :site_name
  validates_presence_of :site_name
  validates_presence_of :site_url
  validates_format_of :xdm_iframe_path, :with => /^\/[^ ]+/, :allow_blank => true, :message => "must be a local path Ex. /liftium_iframe.html"
  validates_numericality_of :beacon_throttle, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1
  validates_inclusion_of :category, :in => CATEGORIES, :message => "must be one of: " + CATEGORIES.join(', '), :allow_blank => true
  validates_inclusion_of :privacy_policy, :in => [true, false], :allow_blank =>true


   ### make sure all urls start with http(s?). See FB 32
   def site_url=(url)
      ###  have to strip the url, in case there is whitespace
      url.strip!

      ### this will catch any malformed uris
      if url.length > 0
         url = URI.parse( url =~ /^https?/i ? url : 'http://' + url ).to_s
      end

      write_attribute( :site_url, url )
   end

   def privacy_policy_s
      privacy_policy ? "Yes" : "No"
   end
   
   def active_networks( limit=0 )
       i = limit ? limit.to_i : 0
       
       ### is there not 'grep'? :(
       networks = self.tags.map { |tag| 
                    if i > 0
                      tag.network.id == i ? tag.network : nil
                    else 
                      tag.network
                    end  
                  }      

       ### remove 'nil' with compact   
       networks.compact!
       networks.uniq!
       return networks
   end

end
