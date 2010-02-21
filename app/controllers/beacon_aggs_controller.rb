class BeaconAggsController < ApplicationController
  def index
  #  @beacon_aggs = BeaconAgg.all(:limit=>100)
  end

  def fill_rate_by_country
#    @beacon_aggs = BeaconAgg.find_by_sql("select id, country, sum(loads) as loads, sum(rejects) as rejects, sum(loads) + sum(rejects) as total_attempts, sum(loads)/(sum(loads)+sum(rejects)) as fillrate from beacon_agg group by country order by total_attempts desc")
    @beacon_aggs = BeaconAgg.find_by_sql("SELECT 
SUM(b.loads) AS loads, 
SUM(b.rejects) AS rejects, 
SUM(b.loads)/(SUM(b.rejects)+SUM(b.loads)) AS fillrate, 
b.country AS country, 
n.network_name AS network_name
FROM 
analysis.beacon_agg AS b 
INNER JOIN liftium.tags AS t ON (b.tagid = t.id) 
INNER JOIN liftium.networks AS n ON (t.network_id = n.id) 
GROUP BY 
n.network_name,
b.country
ORDER BY
b.country asc, fillrate desc, loads desc
")
  end

  def fill_rate_by_hour
      @beacon_aggs = BeaconAgg.find_by_sql("
SELECT
HOUR(hour) AS hour_of_day,
SUM(b.loads) AS loads, 
SUM(b.rejects) AS rejects, 
SUM(b.loads)/(SUM(b.rejects)+SUM(b.loads)) AS fillrate, 
n.network_name 
FROM 
analysis.beacon_agg AS b 
INNER JOIN liftium.tags AS t ON (b.tagid = t.id) 
INNER JOIN liftium.networks AS n ON (t.network_id = n.id) 
GROUP BY 
n.network_name,
hour_of_day
")
  end

  def fill_rate_by_previous_attempts
      @beacon_aggs = BeaconAgg.find_by_sql("SELECT
n.network_name,
b.previous_attempts,
SUM(b.loads) AS loads, 
SUM(b.rejects) AS rejects, 
SUM(b.loads)/(SUM(b.rejects)+SUM(b.loads)) AS fillrate
FROM 
analysis.beacon_agg AS b 
INNER JOIN liftium.tags AS t ON (b.tagid = t.id) 
INNER JOIN liftium.networks AS n ON (t.network_id = n.id) 
GROUP BY 
b.previous_attempts,
n.network_name
ORDER BY
n.network_name,
b.previous_attempts")
  end
  
  def show
    @beacon_agg = BeaconAgg.find(params[:id])
  end
  
  def new
    @beacon_agg = BeaconAgg.new
  end
  
  def create
    @beacon_agg = BeaconAgg.new(params[:beacon_agg])
    if @beacon_agg.save
      flash[:notice] = "Successfully created beacon agg."
      redirect_to @beacon_agg
    else
      render :action => 'new'
    end
  end
  
  def edit
    @beacon_agg = BeaconAgg.find(params[:id])
  end
  
  def update
    @beacon_agg = BeaconAgg.find(params[:id])
    if @beacon_agg.update_attributes(params[:beacon_agg])
      flash[:notice] = "Successfully updated beacon agg."
      redirect_to @beacon_agg
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @beacon_agg = BeaconAgg.find(params[:id])
    @beacon_agg.destroy
    flash[:notice] = "Successfully destroyed beacon agg."
    redirect_to beacon_aggs_url
  end
end
