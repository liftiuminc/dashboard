class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    @changelogs = find_changelogs(params[:record_id], params[:record_type])
  end

  private

  def find_changelogs(record_id = nil, record_type = nil)
    if record_id && record_type
      Changelog.find_all_by_record_id_and_record_type(record_id, record_type)
    else
      Changelog.find(:all)
    end
  end
end
