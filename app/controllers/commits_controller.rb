class CommitsController < ApplicationController
  before_filter :require_admin

  def index
    @entries = "all"
    @excluded_user_id = "none"
    @commits = find_commits(params)
  end

  private

  def find_commits(params)
    changelog_ids = find_changlog_ids(params)

    args = {}
    args[:joins] = "INNER JOIN changelogs_commits ON changelogs_commits.commit_id = commits.id"
    args[:conditions] = ["changelogs_commits.changelog_id IN (?)", changelog_ids.collect(&:id)]
    args[:order] = "created_at DESC"
    args[:limit] = @entries = params[:entries].to_i if params[:entries] && params[:entries] != "all"

    Commit.find(:all, args)
  end

  def find_changlog_ids(params)
    args = {}
    args[:select] = "changelogs.id"
    args[:joins] = "INNER JOIN changelogs_commits ON changelogs_commits.changelog_id = changelogs.id"
    args[:conditions] = ["changelogs.record_id = ? AND changelogs.record_type = ?", params[:record_id], params[:record_type]] if params[:record_id] && params[:record_type]
    args[:conditions] = ["changelogs.user_id = ?", params[:user_id]] if params[:user_id]
    args[:conditions] = ["changelogs.user_id <> ?", @excluded_user_id = params[:excluded_user_id]] if params[:excluded_user_id] && params[:excluded_user_id] != "none"

    Changelog.find(:all, args)
  end
end
