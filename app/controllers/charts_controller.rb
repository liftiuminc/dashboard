class ChartsController < ApplicationController

  ### charts are only for admins according to Nick. See FB 123
  before_filter :require_admin

  def tag
    @tag = Tag.find(params[:id])
  end

  def misc_stat
  end

end
