class ChangelogsController < ApplicationController
  before_filter :require_admin

  def index
    @changelogs = Changelog.find(:all, build_find_args(params))
    @record_types = Changelog.find( :all, :select => 'DISTINCT record_type' ).map{ |i| i.record_type }
  end

  def show
    @changelog = Changelog.find(params[:id])
  end

  private

  def build_find_args(params)
    args = {}
    args[:conditions] = ["1=1"];
    if params[:record_type]
      args[:conditions][0] += " AND record_type = ?"
      args[:conditions].push(params[:record_type])
    end

    if params[:record_id]
      args[:conditions][0] += " AND record_id = ?"
      args[:conditions].push(params[:record_id])
    end

    if params[:user_id]
      args[:conditions][0] += " AND user_id = ?"
      args[:conditions].push(params[:user_id])
    end 

    args[:order] = "created_at DESC"
    if (params[:entries].to_i == 0)
      args[:limit] = 100
    else
      args[:limit] = params[:entries]
    end
    args
  end
end
