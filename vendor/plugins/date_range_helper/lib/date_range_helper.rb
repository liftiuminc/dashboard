class DateRangeHelper

  def timeframes 
    ["This Hour", "Last Hour", "Last 3 Hours", "Last 12 Hours",
     "Today", "Yesterday", "Last 7 Days", "This Month", "Last 30 days",
     "This Quarter", "Last Quarter", "This Year", "All Time"] 
  end

  def get_date_range(timeframe)
   now = DateTime.now
   dates = [nil, nil]

   # TODO: Timezones
   case timeframe.to_s.downcase
      when "this hour"
        dates[0] = now.strftime('%Y-%m-%d %H:00:00')
      when "last 15 minutes"
        dates[0] = (now - 15.minutes).strftime('%Y-%m-%d %H:%M:00')
        dates[1] = now.strftime('%Y-%m-%d %H:%M:00')
      when "last 60 minutes"
        dates[0] = (now - 60.minutes).strftime('%Y-%m-%d %H:%M:00')
        dates[1] = now.strftime('%Y-%m-%d %H:%M:00')
      when "last hour"
        dates[0] = (now - 1.hour).strftime('%Y-%m-%d %H:00:00')
        dates[1] = now.strftime('%Y-%m-%d %H:00:00')
      when "last 3 hours"
        dates[0] = (now - 3.hours).strftime('%Y-%m-%d %H:00:00')
        dates[1] = now.strftime('%Y-%m-%d %H:00:00')
      when "last 12 hours"
        dates[0] = (now - 12.hours).strftime('%Y-%m-%d %H:00:00')
        dates[1] = now.strftime('%Y-%m-%d %H:00:00')
      when "today"
        dates[0] = now.strftime('%Y-%m-%d 00:00:00')
      when "yesterday"
        dates[0] = (now - 1.day).strftime('%Y-%m-%d 00:00:00')
        dates[1] = now.strftime('%Y-%m-%d 00:00:00')
      when "last 7 days"  || "last week"
        dates[0] = (now - 7.days).strftime('%Y-%m-%d 00:00:00')
        dates[1] = now.strftime('%Y-%m-%d 00:00:00')
      when "this month" || "month to date"
        dates[0] = now.strftime('%Y-%m-01 00:00:00')
        dates[1] = now.strftime('%Y-%m-%d 00:00:00')
      when "last 30 days"
        dates[0] = (now - 30.days).strftime('%Y-%m-%d 00:00:00')
        dates[1] = now.strftime('%Y-%m-%d 00:00:00')
      when "this quarter" || "quarter to date"
        month = now.strftime("%m").to_i
        if month.modulo(3) == 1 # jan, apr, jul, oct
             dates[0] = now.strftime('%Y-%m-01 00:00:00')
        elsif month.modulo(3) == 2 # feb, may, aug, nov
             dates[0] = (now - 1.month).strftime('%Y-%m-01 00:00:00')
        elsif month.modulo(3) == 0 # mar, jun, sep, nov
             dates[0] = (now - 2.month).strftime('%Y-%m-01 00:00:00')
        end
        dates[1] = now.strftime('%Y-%m-%d 00:00:00')

      when "last quarter"
        month = now.strftime("%m").to_i
        if month.modulo(3) == 1 # jan, apr, jul, oct
             dates[0] = (now - 3.month).strftime('%Y-%m-01 00:00:00')
             dates[1] = now.strftime('%Y-%m-01 00:00:00')
        elsif month.modulo(3) == 2 # feb, may, aug, nov
             dates[0] = (now - 4.month).strftime('%Y-%m-01 00:00:00')
             dates[1] = (now - 1.month).strftime('%Y-%m-01 00:00:00')
        elsif month.modulo(3) == 0 # mar, jun, sep, nov
             dates[0] = (now - 5.month).strftime('%Y-%m-01 00:00:00')
             dates[1] = (now - 2.month).strftime('%Y-%m-01 00:00:00')
        end

      when "this year" || "year to date"
        dates[0] = now.strftime('%Y-01-01 00:00:00')
        dates[1] = now.strftime('%Y-%m-%d 00:00:00')
      when "last year"
        dates[0] = (now - 1.year).strftime('%Y-01-01 00:00:00')
        dates[1] = now.strftime('%Y-01-01 00:00:00')
      when "all time"
        # no op
    end
    return dates
  end
  
end
