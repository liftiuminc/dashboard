class JavascriptError < ActiveRecord::Base
  attr_accessible :error_type, :language, :browser, :ip, :message
end
