class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    @changelogs = find_changelogs(params)
  end

  private

  def find_changelogs(params)
    if params[:record_id] && params[:record_type]
      Changelog.find_all_by_record_id_and_record_type(params[:record_id], params[:record_type])
    elsif params[:user_id]
      Changelog.find_all_by_user_id(params[:user_id])
    else
      Changelog.find(:all)
    end
  end
end
