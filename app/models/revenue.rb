class Revenue < ActiveRecord::Base
  attr_accessible :attempts, :rejects, :clicks, :revenue, :ecpm, :day, :tag_id, :user_id
end
