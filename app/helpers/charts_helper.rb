module ChartsHelper

  def tag_sparkline_url(tag, range="1h", width=50, height=25) 
	# http://rgraph.liftium.com/sparkline?net=<%=tag.network_id%>&tag=<%=tag.id%>&range=15m&width=50&height=25
	data = {
		:net => tag.network_id,
		:tag => tag.id,
		:range => range,
		:width => width,
		:height => height,
	}

	Conf.rgraph_base_url + "sparkline?" + data.to_query
  end

  def tag_fillrate_url(tag, range="1h", width=600, height=250) 
   	range = self.clean_range(range)
	time = self.get_time_from_range(range)

	data = {
		:net => tag.network_id,
		:tag => tag.id,
		:range => range,
		:title => time + " Stats for " + tag.tag_name,
		:width => width,
		:height => height,
	}

	Conf.rgraph_base_url + "chart?" + data.to_query
  end

  def misc_stat_types 
     ["RemnantRevenue", "BeaconCalls", "TotalAdsServed", "SlotTimeouts", "HopsPerAd", "JavascriptErrors", "TagErrors"]
  end

  def misc_stat_url (stat, range="1h", width=600, height=250)
   	range = self.clean_range(range)
	time = self.get_time_from_range(range)

	data = {
		:stat => stat,
		:range => range,
		:title => self.misc_stat_humanize(stat) + " " + time,
		:width => width,
		:height => height
	}

	Conf.rgraph_base_url + "misc?" + data.to_query
  end

  def date_select_to_graph_range (date_select) 
    matches = date_select.to_s.match(/([0-9]+) (Minute|Hour|Day|Month|Year)s/)
    if matches.nil?
      return "59m" # error, default
    elsif matches[2] == "Minute"
      return matches[1] + "m"
    elsif matches[2] == "Hour"
      return matches[1] + "h"
    elsif matches[2] == "Day"
      return matches[1] + "d"
    elsif matches[2] == "Week"
      return matches[1] + "w"
    elsif matches[2] == "Month"
      return matches[1] + "month"
    elsif matches[2] == "Year"
      return matches[1] + "y"
    else 
      return "58m" # error, default
    end
  end

  def misc_stat_humanize (stat)
     if stat[-1,1] == "s"
	stat.tableize.humanize.titleize 
     else
	stat.tableize.singularize.humanize.titleize 
     end
  end

  # 1m => Monthly, etc.
  def get_time_from_range (range)
      case range[1,1]
	when "h"
	  return "Hourly"
	when "d"
	  return "Daily"
	when "w"
	  return "Weekly"
	when "m"
	  return "Monthly"
	when "y"
	  return "Yearly"
	else 
	  return ""
      end
  end

  # "m" is confusing because it could be monthly or minute, so RRD handles it differently
  def clean_range (range)
	if range[1,1] == "m"
	  return range + "onth"
        else 
          return range
	end
  end

end
