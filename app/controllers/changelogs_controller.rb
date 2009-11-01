class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    @changelogs = Changelog.find(:all)
  end

end
