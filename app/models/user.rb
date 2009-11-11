class User < ActiveRecord::Base
  acts_as_authentic

  belongs_to :publisher
  has_many   :revenues

  validate :must_associate_publisher_if_not_admin

  validates_presence_of :email
  validates_presence_of :password,              :if => :password_required?
  validates_presence_of :password_confirmation, :if => :password_required?

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

  def is_admin?
    (admin and !admin.to_s.empty?) ? true : nil
  end
  
  def is_power_user?
    ((power_user and !power_user.to_s.empty?) or self.is_admin?) ? true : nil
  end
  
  private

  def password_required?
    new_record? || !password.blank?
  end
end
