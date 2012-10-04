class Shift < ActiveRecord::Base
  
  # Relationships
  has_many :shift_jobs, :dependent => :destroy
  has_many :jobs, :through => :shift_jobs
  belongs_to :assignment
  has_one :store, :through => :assignment
  has_one :employee, :through => :assignment
  
    
  # allows shift to have a multi-model form with jobs
  accepts_nested_attributes_for :shift_jobs, :reject_if => lambda{ |shift_job| shift_job[:job_id].blank? }
  
  
  # Validations
  validates_date :date, :on_or_after => lambda { :assignment_starts }, :on_or_after_message => "must be on or after the start of the assignment"
  # validates_date :date, :on_or_after => lambda { self.assignment.start_date.to_date }, :on_or_after_message => "must be on or after the start of the assignment"
  validates_time :start_time #, :between => [Time.local(2000,1,1,11,0,0), Time.local(2000,1,1,23,0,0)]
  validates_time :end_time, :after => :start_time, :allow_blank => true
  validate :assignment_must_be_current
  validates_numericality_of :assignment_id, :only_integer => true, :greater_than => 0
  
  
  # Scopes
  scope :completed, joins(:shift_jobs).group(:shift_id)
  scope :incomplete, joins("LEFT JOIN shift_jobs ON shifts.id = shift_jobs.shift_id").where('shift_jobs.job_id IS NULL')
  # alternative ways of finding 'incomplete' scope:
  # scope :incomplete, where('id NOT IN (?)', Shift.completed.map(&:id))
  # also see the class method 'not_completed' further on down...
  scope :for_store, lambda {|store_id| joins(:assignment, :store).where("assignments.store_id = ?", store_id) }
  scope :for_employee, lambda {|employee_id| joins(:assignment, :employee).where("assignments.employee_id = ?", employee_id) }
  scope :past, where('date < ?', Date.today)
  scope :upcoming, where('date >= ?', Date.today)
  scope :for_next_days, lambda {|x| where('date BETWEEN ? AND ?', Date.today, x.days.from_now.to_date) }
  scope :for_past_days, lambda {|x| where('date BETWEEN ? AND ?', x.days.ago.to_date, 1.day.ago.to_date) }
  scope :chronological, order(:date, :start_time)
  scope :by_store, joins(:assignment, :store).order(:name)
  scope :by_employee, joins(:assignment, :employee).order(:last_name, :first_name)
  
  scope :for_assignment, lambda {|assignment_id| where('assignment_id = ?', assignment_id) }
  
  # a class method to also find incomplete shifts using array operations...
  # def self.not_completed
  #   all_shifts = Shift.all
  #   completed_shifts = Shift.completed
  #   incompleted_shifts = all_shifts - completed_shifts
  # end

  # Other methods
  def completed?
    # ShiftJob.find_all_by_shift_id(self.id).size > 0
    self.shift_jobs.count > 0
  end
  
  def get_shift_length
    time = (self.end_time - self.start_time) / (60 * 60)
    if (time < 0)
      time_before_midnight = Time.local(2012,1,1,23,45,0).to_time
      time_after_midnight = Time.local(2012,1,1,0,15,0).to_time
      return ((time_before_midnight - self.start_time) + (self.end_time - time_after_midnight) + 1800) / (60 * 60)
    else
      return time
    end
  end
  
  # callback to set default end_time (on create only)
  before_create :set_shift_end_time
  

  private
  def assignment_starts
    @assignment_starts = self.assignment.start_date.to_date
  end
  
  def assignment_must_be_current
    unless self.assignment.nil? || self.assignment.end_date.nil?
      errors.add(:assignment_id, "is not a current assignment at the creamery")
    end
  end
  
  def set_shift_end_time
    self.end_time = self.start_time + (3*60*60)
  end
end
