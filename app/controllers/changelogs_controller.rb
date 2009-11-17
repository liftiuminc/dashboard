class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    if params[:record_id] && params[:record_type]
      @changelogs = Changelog.find_all_by_record_id_and_record_type(params[:record_id], params[:record_type])
    else
      @changelogs = Changelog.find(:all)
    end
  end

  def show
    @changelog = Changelog.find(params[:id])
  end

end
