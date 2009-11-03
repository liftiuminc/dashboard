$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'model/changelog'
require 'active_record/acts/changelogable'

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Changelogable }

