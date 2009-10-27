class Revenue < ActiveRecord::Base
  attr_accessible :attempts, :rejects, :clicks, :revenue, :ecpm, :revenue_date
end
