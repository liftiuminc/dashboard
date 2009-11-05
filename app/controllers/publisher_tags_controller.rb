class PublisherTagsController < ApplicationController
  before_filter :require_user
  
  def index
    @publisher_tags = Tag.all(:conditions => ["publisher_id = ?", current_user.publisher_id])
  end
  
end
