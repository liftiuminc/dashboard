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
        ### depending on pay type, we need to use a different method
        ### XXX FIXME some duplication here, clean me up

        if r.tag.network.pay_type == 'Per Click'

            ### calculate missing ecpm
            if r.revenue and r.clicks and ( not r.ecpm or not r.ecpm.length )
                r.ecpm = ( r.revenue / r.clicks ) * 1000

            ### calculate missing attempts
            elsif r.revenue and r.ecpm and ( not r.clicks or not r.clicks.length )
                r.clicks = ( r.revenue * r.ecpm ) / 1000
            end

            ### per click networks will never reject
            r.rejects = 0

        elsif r.tag.network.pay_type == 'Per Impression'

            ### calculate missing ecpm
            if r.revenue and r.attempts and ( not r.ecpm or not r.ecpm.length )
                r.ecpm = ( r.revenue / r.attempts ) * 1000

            ### calculate missing attempts
            elsif r.revenue and r.ecpm and ( not r.attempts or not r.attempts.length )
                r.attempts = ( r.revenue * r.ecpm ) / 1000
            end

        end

        ### format the date
        r.day = r.day.to_date.to_s
    }
end
