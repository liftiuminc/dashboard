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


   def self.revenues_table (criteria)
	query = ["SELECT revenues.id, COALESCE(revenues.tag_id, fills_day.tag_id) AS tag_id," + 
		" revenues.user_id, revenues.attempts AS impressions, revenues.rejects," + 
		" revenues.clicks, revenues.revenue, revenues.ecpm, " + 
		" COALESCE(revenues.day, fills_day.day) AS day, fills_day.attempts AS liftium_attempts," +
		" fills_day.rejects AS liftium_rejects, fills_day.loads AS liftium_loads" +
		" FROM fills_day" + 
		" LEFT OUTER JOIN revenues ON fills_day.tag_id = revenues.tag_id AND revenues.day = fills_day.day" + 
		" INNER JOIN TAGS ON tags.id = fills_day.tag_id" +
		" WHERE fills_day.attempts > 1000 "]

	if criteria["publisher_id"] && criteria["publisher_id"].to_i > 0
	  query[0] += " AND tags.publisher_id = ?"
	  query.push(criteria["publisher_id"])
        end

	if criteria["network_id"] && criteria["network_id"].to_i > 0
	  query[0] += " AND tags.network_id = ?"
	  query.push(criteria["network_id"])
        end

	{   :start_date     => "AND fills_day.day  >= ?",
	    :end_date       => "AND fills_day.day <= ?"
	}.each do |param, condition|
	  if !criteria[param].to_s.blank?
	    query[0] += condition 
	    query.push( criteria[param].to_time.to_s( :db ) )
	  end
	end

	# Only show blank ones
	if criteria["only_empty"]
	   query[0] += " AND revenues.revenue IS NULL"
	end

        query[0] += " ORDER BY tags.publisher_id, tags.network_id, tag_id, day DESC "

	if !criteria["limit"]
          query[0] += " LIMIT 100"
        else 
          query[0] += " LIMIT " + criteria.to_i.to_s
	end

	find_by_sql(query)
   end
end
