# controller for the home page

class HomeController < ApplicationController
  def home
      if logged_in?
        # get whatever I need for each dashboard here
        if @current_user.employee.role == 'employee'
           get_employees_data
        elsif @current_user.employee.role == 'manager'
           get_managers_data
        elsif @current_user.employee.role == 'admin'
           get_admins_data
        end
      else
        # get all the active stores in alphabetical order
        @stores_active = Store.active.alphabetical.paginate(:page => params[:page]).per_page(5)
      end
  end
  
  def search
    @query = params[:query]
    @employees_search = Employee.search(@query).alphabetical
  end

end


def get_employees_data
  # the current user (an employee)
  @employee = @current_user.employee
  # all of the shifts in the past for this employee
  @previous_shifts = Shift.for_employee(@employee.id).past.paginate(:page => params[:prev_shifts]).per_page(5)
  # all of the upcoming shifts in the next two weeks for this employee
  @upcoming_shifts = Shift.for_employee(@employee.id).for_next_days(14).paginate(:page => params[:coming_shifts]).per_page(5)
end

def get_managers_data
  # the current user (a manager)
  @manager = @current_user.employee
  # the store the manager is assgiend to
  if !(@manager.current_assignment.nil?)
    @store = @manager.current_assignment.store
    # get all assignment at the store in order (used to get all employees at the store)
    @assignments = Assignment.current.for_store(@store.id).by_employee.paginate(:page => params[:page]).per_page(6) 
    # all of the shifts in the past 14 days
    @shifts_past = Shift.for_past_days(14).for_store(@store.id)
    # all of todays shifts
    @todays_shifts = Shift.for_store(@store.id).chronological.for_next_days(0).paginate(:page => params[:todays]).per_page(6)
    # all of the incomplete shifts in chronological order
    @incomplete_shifts = Shift.for_store(@store.id).chronological.incomplete.paginate(:page => params[:incomplete]).per_page(6)
  else
    @store = nil
    @assignments = nil
    @shifts_past = nil
    @todays_shifts = nil
    @incomplete_shifts = nil
  end
end

def get_admins_data
  # get all the active stores ordered alphabetically
  @stores = Store.alphabetical.active.paginate(:page => params[:page]).per_page(6)
  # get all the shifts in the past 14 days and order by employee        
  @past_shifts = Shift.for_past_days(14).by_employee
  # hash to hold employee => total hours in last two weeks       
  @employee_hours = {}
  
  # loop through all past shifts
  @past_shifts.each do |shift|
    # if there are no employee hours for that employee yet
    if @employee_hours[shift.employee] == nil
      # set the employee hours to that shift length
      @employee_hours[shift.employee] = shift.get_shift_length
    else # there are already hours in the hash
      # add to the existing hours
      @employee_hours[shift.employee] += shift.get_shift_length
    end
  end
  # sort by value
  @employee_hours_array = @employee_hours.sort_by { |key, value| value }
  # reverse the order
  @employee_hours_array.reverse!
end