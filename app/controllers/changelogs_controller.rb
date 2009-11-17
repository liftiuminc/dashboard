class ChangelogsController < ApplicationController
  before_filter :require_admin

  def show
    @changelog = Changelog.find(params[:id])
  end

end
