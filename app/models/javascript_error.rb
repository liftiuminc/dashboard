class JavascriptError < ActiveRecord::Base
  belongs_to :publisher
  belongs_to :tag
end
