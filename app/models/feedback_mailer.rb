class FeedbackMailer < ActionMailer::Base
  
  def feedback(feedback)
    @recipients  = 'nick@liftium.com'
    @from        = 'noreply@liftium.com'
    @subject     = "[Feedback for Liftium] #{feedback.subject}"
    @sent_on     = Time.now
    @body[:feedback] = feedback    
  end

end
