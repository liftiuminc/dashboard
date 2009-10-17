class Network < ActiveRecord::Base
  require 'uri'

  # FIXME
  @all_pay_types = ["Per Click", "Per Impression", "Affliate" ]

  has_many :network_tag_options, :dependent => :destroy
  accepts_nested_attributes_for :network_tag_options, :allow_destroy => true, :reject_if => proc { |a| a['option_name'].blank? }

  validates_uniqueness_of :network_name
  validates_presence_of :network_name, :pay_type
  validates_inclusion_of :enabled, :in => [true, false]
  validates_inclusion_of :default_always_fill, :in => [true, false]
  validates_inclusion_of :supports_threshold, :in => [true, false]
  validates_inclusion_of :pay_type, :in => @all_pay_types, :message => "must be one of: " + @all_pay_types.join(', ')

   def enabled_s 
      enabled ? "Yes" : "No"
   end

   def supports_threshold_s
      supports_threshold ? "Yes" : "No"
   end

   def default_always_fill_s 
      default_always_fill ? "Yes" : "No"
   end

   def us_only_s 
      us_only ? "Yes" : "No"
   end

   def pay_types 
        ["Per Click", "Per Impression", "Affliate" ]
   end
   
   def network_name_and_id
      network_name.to_s + " (" + id.to_s + ")"
   end

   ### make sure all urls start with http(s?). See FB 32
   def website=(url)

      ### this will catch any malformed uris
      if url.length > 0
         url = URI.parse( url =~ /^https?/i ? url : 'http://' + url ).to_s
      end  
      
      write_attribute( :website, url )
   end

end
