
# controller for employees

class EmployeesController < ApplicationController
  
  # check login before doing any actions
  before_filter :check_login
  # checks CanCan abilities
  authorize_resource

  def index
    # retrieves all of the current employees in the system (paginates list)
    # orders them alphabetically
    @employees_active = Employee.active.alphabetical.paginate(:page => params[:active]).per_page(10)
    @employees_inactive = Employee.inactive.alphabetical.paginate(:page => params[:inactive]).per_page(10)
  end

  def show
    # retrieves the emplyee with the parameter specified
    @employee = Employee.find(params[:id])
    # retrieves all assignments for an employee
    @assignments = @employee.assignments.paginate(:page => params[:assignment_page]).per_page(3)
    # retrieves all of an employees upcoming shifts (next 14 days)
    @upcoming_shifts = Shift.for_employee(@employee.id).for_next_days(14).chronological.paginate(:page => params[:shift_page]).per_page(3)
  end

  def new
    # retrieves a new employee
    @employee = Employee.new
  end

  def edit
    # retrieves the employee to edit
    @employee = Employee.find(params[:id])
  end

  def create
    # retrieves the employee to create
    @employee = Employee.new(params[:employee])
    # converts date of birth to saveable date
    @employee.date_of_birth = convert_to_date(params[:employee][:date_of_birth])

    if @employee.save  # if saved to database
      if !@employee.user.nil?
        UserMailer.new_user_message(@employee.user).deliver
      end
      # flash a notice that it was saved
      flash[:notice] = "Successfully created #{@employee.first_name} #{@employee.last_name}."
      redirect_to @employee # go to employee 'show' page
    else  # if the assignment was not saved
      # stay at the 'new' form
      render :action => 'new'
    end
    
  end

  def update
    # retrieves the assignment to update
    @employee = Employee.find(params[:id])
    # update the employees attributes
    @employee.update_attributes(params[:employee])
    # converts date of birth to saveable date
    @employee.date_of_birth = convert_to_date(params[:employee][:date_of_birth])
    
    # if the employee was updated
    if @employee.save
      # flash notice that says it was updated
      flash[:notice] = "Successfully updated #{@employee.name}."
      redirect_to @employee  # go to the employee 'show' page
    else  # if the employee was not updated
      # stay at the 'edit' form
      render :action => 'edit'
    end

  end

  def destroy
    # retrieve the employee to be destroyed
    @employee = Employee.find(params[:id])
    @employee.destroy  # detroy the employee
    
    # flash notice that says employee was removed
    flash[:notice] = "Successfully removed #{@employee.name} from the system."
    # go to the employees index page
    redirect_to employees_url
  end
end
