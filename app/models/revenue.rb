class Revenue < ActiveRecord::Base
    belongs_to :tag
    belongs_to :user

    attr_accessible :attempts, :rejects, :clicks, :revenue, :ecpm, :day

    validates_uniqueness_of :day, :scope => :tag_id

    ### ints
    %w( attempts rejects clicks ).each do |f|
        validates_numericality_of f, 
            :only_integer               => true,
            :greater_than_or_equal_to   => 0, 
            :allow_nil                  => true
    end    
    
    ### floats
    %w( ecpm revenue ).each do |f|
        validates_numericality_of f, 
            :only_integer               => false,
            :greater_than_or_equal_to   => 0, 
            :allow_nil                  => true
    end

    validates_date :day
end
