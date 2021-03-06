class Tag < ActiveRecord::Base
  require "date_range_helper"

  acts_as_changelogable
  acts_as_commentable

  belongs_to :network
  belongs_to :publisher
  has_many :tag_options, :dependent => :destroy
  has_many :tag_targets, :dependent => :destroy
  has_many :revenues,    :dependent => :destroy
  has_many :fills_days

  ### enable comments on tags. See FB 24
  ### Requires db/migrate/20091013122159_add_tag_comments.rb
  accepts_nested_attributes_for :tag_options, :allow_destroy => true, :reject_if => proc { |a| a['option_name'].blank? || a['option_value'].blank? }
  accepts_nested_attributes_for :tag_targets, :allow_destroy => true, :reject_if => proc { |a| a['key_name'].blank? || a['key_value'].blank?}
  validates_format_of :size, :with => /^[0-9]{1,3}x[0-9]{1,3}$/
  validates_uniqueness_of :tag_name, :scope => :publisher_id
  validates_presence_of :tag_name, :network, :size, :publisher
  validates_inclusion_of :enabled, :in => [true, false]
  validates_inclusion_of :always_fill, :in => [true, false]
  validates_numericality_of :tier, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10, :allow_nil => true
  validates_numericality_of :sample_rate, :greater_than_or_equal_to => 0, :less_than => 100, :allow_nil => true
  validates_numericality_of :frequency_cap, :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1000, :allow_nil => true
  validates_numericality_of :rejection_time, :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1440, :allow_nil => true
  validates_numericality_of :value, :greater_than_or_equal_to => 0, :less_than => 100
  validates_numericality_of :floor, :greater_than_or_equal_to => 0, :less_than => 100, :allow_nil => true

#  ### From FB 16: Tags page should not allow "Always fill" with a rejection
#  ### time limit set
#  validate :always_fill_with_rejection_time
#  def always_fill_with_rejection_time
#    if always_fill && rejection_time.to_i > 0
#      errors.add_to_base "Always fill can not be true if rejection time is set"
#    end
#  end

  validate :floor_higher_than_value
  def floor_higher_than_value
    if floor && floor.to_f > 0.0 && value.to_f < floor.to_f
      errors.add_to_base "Value cannot be lower then floor"
    end
  end

  validate :floor_with_always_fill
  def floor_with_always_fill
    if floor && floor.to_f > 0.0 && always_fill
      errors.add_to_base "Always Fill cannot be set with a floor"
    end
  end

   def auto_update_ecpm_s
      auto_update_ecpm ? "Yes" : "No"
   end

  def enabled_s
    if network.enabled 
      enabled ? "Yes" : "No"
    else
      "Network Disabled"
    end
  end

  def always_fill_s
    always_fill ? "Yes" : "No"
  end

  # db returns 0.1. we want this to be 0.10
  def value_s
    sprintf( "%.2f", value.to_f)
  end

  def floor_s
    sprintf( "%.2f", floor.to_f)
  end

  def html
      if tag
	"#{tag}"
      else
        # TODO: Network tag options expansion
	"#{tag.network.tag_template}"
      end
  end

  def width
    d = size.to_s.split("x")
    d[0] || 0
  end

  def height
     d = size.to_s.split("x")
     d[1] || 0
  end

  def css_size
    "width:#{width}px;height:#{height}px;"
  end

  def verbose_size
    s = AdFormat.find_by_size(size)
    "#{s.ad_format_name} (#{size})"
  end

  def get_first_placement 
    for target in tag_targets do
      if target.key_name == 'placement' 
        placements = target.key_value.split(',') 
        return placements[0]
      end
    end
    return ''
  end

  def preview_url
     Conf.delivery_base_url + "tag?tag_id=#{id}&action=purge&cb=" + rand(9999999).to_s + "&placement=" + get_first_placement
  end

  def search_sql (params)
    query = []
    query.push("SELECT tags.* FROM tags 
	INNER JOIN networks ON networks.id = tags.network_id
	WHERE 1=1");

    if (params[:include_disabled].blank?)
       query[0] += " AND tags.enabled = ?"
       query.push(true)
       query[0] += " AND networks.enabled = ?"
       query.push(true)
    end

    if (! params[:publisher_id].blank?)
       query[0] += " AND publisher_id = ?"
       query.push(params[:publisher_id].to_i)
    end

    if (! params[:network_id].blank?)
       query[0] += " AND network_id = ?"
       query.push(params[:network_id].to_i)
    end

    if (! params[:size].blank?)
       query[0] += " AND size = ?"
       query.push(params[:size])
    end

    if (! params[:tier].blank?)
       if params[:tier_clause] == "lower" 
	 symbol = "<="
       elsif params[:tier_clause] == "higher" 
	 symbol = ">="
       else
	 symbol = "="
       end

       query[0] += " AND tier " + symbol + " ?"
       query.push(params[:tier])
    end

    ### created before a certain date?
    ### mysql will not truncate a date to the same amount of significance,
    ### so a tag created DURING '2009-10-10' is not returned for a query
    ### with 'created_at <= 2009-10-10'. The solution is to do <= the
    ## NEXT date -jos
    if (! params[:created_before].blank? )
       query[0] += " AND tags.created_at <= ?"
       query.push( params[:created_before].to_date.next )
    end

    if (! params[:publisher_id].blank?)
       query[0] += " AND publisher_id = ?"
       query.push(params[:publisher_id].to_i)
    end

    ### search for both name & ids
    if (! params[:name_search].blank?)
       query[0] += " AND (tag_name like ? OR network_name like ? OR tags.id = ?) "
       query.push('%' + params[:name_search] + '%')
       query.push('%' + params[:name_search] + '%')
       query.push( params[:name_search] )
    end

    ### exclude key certain key values 
    if (! params[:exclude_target].blank?)
       query[0] += " AND tags.id NOT IN (SELECT tag_id FROM tag_targets WHERE key_name = ?) "
       query.push( params[:exclude_target] )
    end

    ### we're not currently using ':order' anywhere, so the code is
    ### commented out. When we do use :order, we should probably
    ### delegate it to 'active_record_random' which takes care of
    ### the :order on searches, and supports 'random' cross db
    ### implementation -Jos. See FB 108
#     case (params[:order])
#       when "tag_name"
#         query[0] += " ORDER BY tag_name ASC"
#       else
#         # Same order as the chain (without the randomization)
#         query[0] += " ORDER BY tier ASC, value DESC"
#     end
#
    query[0] += " ORDER BY tier ASC, value DESC"

    ### no paging - no limit
#    if (! params[:limit].to_s.empty? && params[:limit].to_i < 300)
#       query[0] += " LIMIT ?"
#       query.push(params[:limit].to_i)
#    else
#       query[0] += " LIMIT 50"
#    end
#
#    if (! params[:offset].blank?)
#       query[0] += " OFFSET ? "
#       query.push(params[:offset].to_i)
#    else
#       query[0] += " OFFSET 0"
#    end

    return query

  end

  def search (params)
    Tag.find_by_sql self.search_sql(params)
  end

  def most_recent_ecpm ( maxage=7 )  
    date = (DateTime.now - maxage.days).strftime('%Y-%m-%d 00:00:00')

    self.revenues.find :first, :conditions => [ 'day >= ?', date ]
  end

  def get_fill_stats_minutes_back (minutes_back)
    sql = "SELECT SUM(attempts) AS attempts, 
                SUM(loads) as loads, SUM(rejects) AS rejects 
                FROM fills_minute WHERE 
                tag_id = " + id.to_s + "
		AND DATE_SUB(NOW(), INTERVAL " + minutes_back.to_i.to_s + " MINUTE) <= minute"
    
    stats = FillsMinute.find_by_sql(sql)
    stat = stats[0]

    fill_rate = FillsBase.calculate_fill_rate(stat.loads, stat.attempts)
    return {:loads => stat.loads.to_i, :attempts => stat.attempts.to_i, :rejects => stat.rejects.to_i, :fill_rate => fill_rate}
  end

  def get_fill_stats (range, date0 = nil, date1 = nil)
    sql = "SELECT SUM(attempts) AS attempts, 
                SUM(loads) as loads, SUM(rejects) AS rejects 
                FROM fills_minute WHERE 
                tag_id = " + id.to_s

    if date0 
      dates = [date0, date1]
    else 
      dates = DateRangeHelper.get_date_range(range)
    end

    if dates[0]
      sql += " AND minute >= '" + dates[0] + "'"
    end
    if dates[1]
      sql += " AND minute <= '" + dates[1] + "'"
    end
    
    stats = FillsMinute.find_by_sql(sql)
    stat = stats[0]

    fill_rate = FillsBase.calculate_fill_rate(stat.loads, stat.attempts)
    return {:loads => stat.loads.to_i, :attempts => stat.attempts.to_i, :rejects => stat.rejects.to_i, :fill_rate => fill_rate}
  end

  # Hack to clean up empty targets and options
  def after_save 
    sql = ActiveRecord::Base.connection();
    sql.execute("DELETE FROM tag_targets WHERE tag_id=" + id.to_s + " AND key_value=''");
    sql.execute("DELETE FROM tag_options WHERE tag_id=" + id.to_s + " AND option_value=''");
  end

end
