class TagTarget < ActiveRecord::Base
  acts_as_changelogable
  
  belongs_to :tags

  ### key_NAME may not be blank, key_value may be blank, in some cases
  validates_presence_of :key_name

  validates_uniqueness_of :key_name, {:scope => :tag_id}

  def all_countries 
    countries = []

    TagTarget.find( :all, :select => 'DISTINCT key_value', :conditions => { :key_name => "country" } ).map do |tt|
      tt.key_value.gsub(/^,/, '').gsub(/,$/, '').split(/\s*,\s*/).map do |c|
        countries.push c.downcase
      end  
    end

    countries.uniq!
    countries.sort!
    
    return countries
  end

  def all_placements 
    placements = []

    TagTarget.find( :all, :select => 'DISTINCT key_value' , :conditions => { :key_name => "placement" } ).map do |tt|
      tt.key_value.gsub(/^,/, '').gsub(/,$/, '').split(/\s*,\s*/).map do |c|
        placements.push c
      end  
    end
    placements.uniq!
    placements.sort!
    
    return placements
  end

  # TODO : Put this into a table
  def get_placement_options (publisher_id)
     if publisher_id == 999 
	out = { 
	   "0x0 INVISIBLE_1" => "INVISIBLE_1",                                        
	   "0x0 INVISIBLE_2" => "INVISIBLE_2", 
	   "0x0 EXIT_STITIAL_INVISIBLE" => "EXIT_STITIAL_INVISIBLE",                  
	   "160x600 HOME_LEFT_SKYSCRAPER_1" => "HOME_LEFT_SKYSCRAPER_1",              
	   "160x600 LEFT_SKYSCRAPER_1" => "LEFT_SKYSCRAPER_1",                        
	   "160x600 LEFT_SKYSCRAPER_2" => "LEFT_SKYSCRAPER_2",                        
	   "160x600 LEFT_SKYSCRAPER_3" => "LEFT_SKYSCRAPER_3",                        
	   "300x250 INCONTENT_BOXAD_1" => "INCONTENT_BOXAD_1",                        
	   "300x250 EXIT_STITIAL_BOXAD_2" => "EXIT_STITIAL_BOXAD_2",                  
	   "300x250 EXIT_STITIAL_BOXAD_1" => "EXIT_STITIAL_BOXAD_1",                  
	   "300x250 SPECIAL_INTERSTITIAL_BOXAD_1" => "SPECIAL_INTERSTITIAL_BOXAD_1",  
	   "300x250 HOME_TOP_RIGHT_BOXAD" => "HOME_TOP_RIGHT_BOXAD",                  
	   "300x250 PREFOOTER_LEFT_BOXAD" => "PREFOOTER_LEFT_BOXAD",                  
	   "300x250 PREFOOTER_RIGHT_BOXAD" => "PREFOOTER_RIGHT_BOXAD",                
	   "300x250 INCONTENT_BOXAD_1" => "INCONTENT_BOXAD_1",                        
	   "300x250 INCONTENT_BOXAD_2" => "INCONTENT_BOXAD_2",                        
	   "300x250 TOP_RIGHT_BOXAD" => "TOP_RIGHT_BOXAD",                            
	   "500x280 RICH_MEDIA_AD_TAG" => "RICH_MEDIA_AD_TAG",                        
	   "600x250 PREFOOTER_BIG" => "PREFOOTER_BIG",                                
	   "728x90 INCONTENT_LEADERBOARD_1" => "INCONTENT_LEADERBOARD_1",             
	   "728x90 HOME_TOP_LEADERBOARD" => "HOME_TOP_LEADERBOARD",                   
	   "728x90 TOP_LEADERBOARD" => "TOP_LEADERBOARD",                             
	   "728x90 INCONTENT_LEADERBOARD_2" => "INCONTENT_LEADERBOARD_2"
	}
	# Odd rails bug
	out.sort
	
     else
	out = { "ATF" => "ATF", "BTF" => "BTF" }
	out.sort
     end
  end

  def key_name_h 
    key_name.gsub(/^kv_/, '')
  end

  def key_value_h 
    key_value.gsub(/^,+/, '').gsub(/,+$/, '').gsub(/,/, ', ')
  end


   # Clean up values before saving
   before_save { |r|
	if r.key_value.is_a?(Array)
	  r.key_value = r.key_value.join(',').gsub(/,$/, '')
        end

	r.key_value = r.key_value.gsub(/ *, */, ',').strip
	r.key_value = r.key_value.gsub(/,+/, ',')
	if !r.key_value.blank?
		r.key_value = ',' + r.key_value + ','
	end
   }

end
