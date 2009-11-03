require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  should_acts_as_changelogable do
    tag = Tag.find(:first)
    user = User.find(:first)
    Comment.create!(:title => "title", :comment => "comment", :commentable_id => tag.id,
                    :commentable_type => tag.class.to_s, :user_id => user.id)
  end

end
