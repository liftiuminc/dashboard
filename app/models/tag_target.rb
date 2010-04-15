class TagTarget < ActiveRecord::Base
  acts_as_changelogable
  
  belongs_to :tags

  ### key_NAME may not be blank, key_value may be blank, in some cases
  validates_presence_of :key_name

  validates_uniqueness_of :key_name, {:scope => :tag_id}

  def all_countries 
    countries = []

    TagTarget.find( :all, :select => 'DISTINCT key_value', :conditions => { :key_name => "country" } ).map do |tt|
      tt.key_value.split(/\s*,\s*/).map do |c|
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
      tt.key_value.split(/\s*,\s*/).map do |c|
        placements.push c
      end  
    end
    placements.uniq!
    placements.sort!
    
    return placements
  end

  def key_name_h 
    key_name.gsub(/^kv_/, '')
  end

   # Clean up values before saving
   before_save { |r|
	if r.key_value.is_a?(Array)
	  r.key_value = r.key_value.join(',')
        end

	r.key_value = r.key_value.gsub(/ *, */, ',').strip
   }

end
