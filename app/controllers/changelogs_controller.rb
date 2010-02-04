class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    @entries = "all"
    @excluded_user_id = "none"
    @changelogs = Changelog.find(:all, build_find_args(params), :limit => 150)
  end

  def show
    @changelog = Changelog.find(params[:id])
  end

  private

  def build_find_args(params)
    args = {}
    args[:conditions] = ["record_id = ? AND record_type = ?", params[:record_id], params[:record_type]] if params[:record_id] && params[:record_type]
    args[:conditions] = ["user_id = ?", params[:user_id]] if params[:user_id]
    args[:conditions] = ["user_id <> ?", @excluded_user_id = params[:excluded_user_id]] if params[:excluded_user_id]
    args[:order] = "created_at DESC"
    args[:limit] = @entries = params[:entries].to_i if params[:entries] && params[:entries] != "all"
    args
  end
end
