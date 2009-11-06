require File.dirname(__FILE__) + '/../test_helper'

class FeedbackTest < Test::Unit::TestCase
  
  
  def test_should_require_comment
    assert !create_comment(:comment => " ").valid?
  end
  
  def test_should_be_valid
    assert create_comment.valid?
  end
  
  protected
  
  def create_comment(params = {})
    valid_feedback = {
      :subject => "Test",
      :email => "test@yoursite.com",
      :comment => "i like the site"
    }
    Feedback.new(valid_feedback.merge(params))    
  end
  
end