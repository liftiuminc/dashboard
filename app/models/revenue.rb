class Revenue < ActiveRecord::Base
    belongs_to :tag
    belongs_to :user

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
    validates_numericality_of   :tag_id,    :greater_than => 0
    validates_numericality_of   :user_id,   :greater_than => 0

    validates_each :tag_id do |record, attr, value|
        record.errors.add attr, "No such tag #{value}" unless Tag.find_by_id(value)
    end

    validates_each :user_id do |record, attr, value|
        record.errors.add attr, "No such user #{value}" unless User.find_by_id(value)
    end

    ### fix up the record so we have all our fields in order
    ### also verify settings based on pay type
    before_save { |r|
        ### calculate missing ecpm
        if r.revenue and r.attempts and ( not r.ecpm or not r.ecpm > 0 )
            r.ecpm = calculate_ecpm( r.attempts, r.revenue)

        ### calculate missing attempts
        elsif r.revenue and r.ecpm and ( not r.attempts or not r.attempts > 0 )
            r.attempts = ( r.revenue * r.ecpm ) / 1000
        end

        ### pay per click never rejects
        if r.tag.network.pay_type == 'Per Click'
            r.rejects = 0
        end

        ### format the date
        r.day = r.day.to_date.to_s
    }
    
    ### update ecpm if the tag's setup to do so
    after_save { |r|
      tag = r.tag
      if tag.auto_update_ecpm
        if rev = tag.most_recent_ecpm
          tag.value = rev.ecpm
          tag.save
        end
      end
    }

    def self.calculate_ecpm (impressions, revenue)
        i = impressions.to_i
        r = revenue.to_f
        if (i.zero? or r.zero?)
            return 0.00
        end

        return ( r / i ) * 1000
    end
end
