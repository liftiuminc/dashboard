class FillsBase < ActiveRecord::Base

  belongs_to :tag

  def fill_rate 
    self.fill_rate_raw(loads, attempts)
  end

  def slip
    attempts - (loads + rejects)
  end

  def fill_rate_raw (loads, attempts)
    ((loads.to_f/attempts.to_f).to_f.round(4) * 100)
  end
  
  def search_sql (model, params)

    col = model.new.time_column
    query = []
    query.push("SELECT * FROM " + model.table_name + " INNER JOIN tags ON " + model.table_name + ".tag_id = tags.id WHERE 1=1");

    if (params[:include_disabled].blank?)
       query[0] += " AND enabled = ?"
       query.push(1)
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

    if (! params[:name_search].blank?)
       query[0] += " AND tag_name like ?"
       query.push('%' + params[:name_search] + '%')
    end

    # Date / time
    case params[:date_select].to_s.downcase
      when "today"
        params[:start_date] = DateTime.now.strftime('%Y-%m-%d 00:00:00')
      when "yesterday"
        params[:start_date] = 1.day.ago.strftime('%Y-%m-%d 00:00:00')
        params[:end_date] = DateTime.now.strftime('%Y-%m-%d 00:00:00')
      when "last 7 days"
        params[:start_date] = 7.days.ago.strftime('%Y-%m-%d 00:00:00')
        params[:end_date] = DateTime.now.strftime('%Y-%m-%d 00:00:00')
      when "this month"
        params[:start_date] = DateTime.now.strftime('%Y-%m-01 00:00:00')
        params[:end_date] = DateTime.now.strftime('%Y-%m-%d 00:00:00')
    end
    

    if (! params[:start_date].blank?)
       query[0] += " AND " + col + " >= ? "
       query.push(params[:start_date].to_time.to_s(:db))
    end

    if (! params[:end_date].blank?)
       query[0] += " AND " + col + " <= ? "
       query.push(params[:end_date].to_time.to_s(:db))
    end

    case (params[:order])
      when "tag_name"
	query[0] += " ORDER BY " + tag_name + " ASC"
      else 
	query[0] += " ORDER BY " + col + " ASC"
    end

    if (! params[:limit].to_s.empty?)
       query[0] += " LIMIT ?"
       query.push(params[:limit].to_i)
 
      if (! params[:offset].blank?)
         query[0] += " OFFSET ? "
         query.push(params[:offset].to_i)
      else
         query[0] += " OFFSET 0"
      end
    end

    return query
      
  end

  def search (model, params)
    model.find_by_sql self.search_sql(model, params)
  end 

end
