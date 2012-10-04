class User < ActiveRecord::Base
  
  has_secure_password
  
  # Relationship
  belongs_to :employee
  
  attr_accessible :email, :password, :password_confirmation, :employee_id
  
  # Validations
  validates_uniqueness_of :email, :allow_blank => true, :message => 'email already being used.'
  validates_format_of :email, :allow_blank => true, :with => /^[\w]([^@\s,;]+)@(([\w-]+\.)+(com|edu|org|net|gov|mil|biz|info))$/i, :message => "is not a valid format"
  validate :employee_is_active_in_system
  
  
  ROLES = [['admin', :admin], ['manager', :manager], ['employee', :employee]]
  def role?(authorized_role)
    if self.employee_id.nil?
      return false
    end
    return false if self.employee.role.nil?
    employee.role.to_sym == authorized_role
  end
  
  private
  def employee_is_active_in_system
    all_active_employees = Employee.active.all.map{|e| e.id}
    unless all_active_employees.include?(self.employee_id) || self.employee_id.nil?
      errors.add(:employee_id, "is not an active employee at the creamery")
    end
  end
  
  def self.authenticate(email, password)
    find_by_email(email).try(:authenticate, password)
  end
  
end
