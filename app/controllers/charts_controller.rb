class ChartsController < ApplicationController

  ### charts are only for admins according to Nick. See FB 123
  ### Overriden by FB 131: Power users must be able to see it as well
  before_filter :require_power_user

  def tag
    @tag = Tag.find(params[:id])
  end

  def misc_stat
  end

end
