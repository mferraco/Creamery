# controller for shifts

class ShiftsController < ApplicationController

  # checks if the user is logged in before any actions
  before_filter :check_login
  # only loads the jobs if creating or editting a shift
  before_filter :load_jobs, :only => [:new, :create, :edit, :update]
  # checks CanCan abilities
  authorize_resource

  def index
    # retrieves the incomplete shifts and orders by store
    @shifts_current = Shift.incomplete.by_store.by_employee.paginate(:page => params[:current_page]).per_page(10)
    # retrieves the complete shfits and orders by store
    @shifts_complete = Shift.completed.by_store.by_employee.paginate(:page => params[:complete_page]).per_page(10)
  end

  def show
    # retrieves the shift to show
    @shift = Shift.find(params[:id])
    # retrieves the shift _jobs associated with that shift
    @shift_jobs = ShiftJob.for_shift(@shift.id)
  end

  def new
    # instantiates a new shift
    @shift = Shift.new
    # sets the assignments_id if it is known to populate form
    @shift.assignment_id = params[:assignment_id]
  end

  def edit
    # retrieves the shift to edit
    @shift = Shift.find(params[:id])
  end

  def create
    # converts the time into a saveable format
    params[:shift].parse_time_select! :start_time
    #creates a new shift
    @shift = Shift.new(params[:shift])
    # converts the date into a saveable format
    @shift.date = convert_to_date(params[:shift][:date])
    
    # saves the shift to the database
    if @shift.save
      # if saved to database
      flash[:notice] = "Shift has been created."
      redirect_to @shift # go to show shift page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    # converts start and end time to saveable format
    params[:shift].parse_time_select! :start_time
    params[:shift].parse_time_select! :end_time
    # retrieves the shift to update
    @shift = Shift.find(params[:id])
    # updates that shift's attributes
    @shift.update_attributes(params[:shift])
    # converts the date into a saveable format
    @shift.date = convert_to_date(params[:shift][:date])
    
    # saves teh shift to the database
    if @shift.save
      flash[:notice] = "Shift has been updated."
      redirect_to @shift
    else
      render :action => 'edit'
    end
  end

  def destroy
    # retrieves the shift to destroy
    @shift = Shift.find(params[:id])
    # destroys that shift
    @shift.destroy
    
    flash[:notice] = "Successfully removed the shift."
    if current_user.employee.role == "manager"
      redirect_to home_path
    else  
      redirect_to shifts_url
    end
  end
  
  private
  def load_jobs
    # retrieves all of teh active jobs and orders them alphabetically
    @jobs = Job.alphabetical.active
  end
end
