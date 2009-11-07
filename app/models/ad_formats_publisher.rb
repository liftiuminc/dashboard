class AdFormatsPublisher < ActiveRecord::Base
  belongs_to :ad_format
  belongs_to :publisher
end
