class TagTarget < ActiveRecord::Base
  acts_as_changelogable
  
  belongs_to :tags

  ### key_NAME may not be blank, key_value may be blank, in some cases
  validates_presence_of :key_name

  validates_uniqueness_of :key_name, {:scope => :tag_id}

  def all_countries 
    countries = []

    TagTarget.find( :all, :conditions => { :key_name => "country" } ).map do |tt|
      tt.key_value.split(/\s*,\s*/).map do |c|
        countries.push c.downcase
      end  
    end

    countries.uniq!
    countries.sort!
    
    return countries
  end

end
