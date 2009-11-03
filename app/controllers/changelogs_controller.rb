class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    @changelogs = find_changelogs(params)
  end

  private

  def find_changelogs(params)
    @entries = "all"
    limit = {:limit => @entries = params[:entries].to_i} if params[:entries] && params[:entries] != "all"

    if params[:record_id] && params[:record_type]
      Changelog.find_all_by_record_id_and_record_type(params[:record_id], params[:record_type], limit)
    elsif params[:user_id]
      Changelog.find_all_by_user_id(params[:user_id], limit)
    else
      Changelog.find(:all, limit)
    end
  end
end
