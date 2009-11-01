class Changelog < ActiveRecord::Base
  set_table_name "acts_as_changelogs"

  belongs_to :user
  belongs_to :record, :polymorphic => true
  
  before_save :set_user

  class << self
    def current_user=(user)
      @@current_user = user
    end
  end

  private

  def set_user
    self.user = @@current_user
  end
end
