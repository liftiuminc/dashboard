require 'rubygems'
require 'active_support'
require 'active_support/test_case'
require 'test/unit'

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

config = YAML::load(IO.read("#{RAILS_ROOT}/config/database.yml"))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

ActiveRecord::Base.establish_connection(config[RAILS_ENV])
load(File.dirname(__FILE__) + "/test_schema.rb")
require File.dirname(__FILE__) + '/../init.rb'
