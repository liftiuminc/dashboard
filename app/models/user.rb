class User < ActiveRecord::Base
  acts_as_authentic

  belongs_to :publisher
  has_many   :revenues

  validate :must_associate_publisher_if_not_admin

  ### no login without email/password
  validates_presence_of :email 


  def must_associate_publisher_if_not_admin
    if !admin and publisher_id.blank?
      errors.add_to_base("If the user is not an administrator, a publisher must be selected")
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def admin_s
    admin ? "Yes" : "No"
  end

end
