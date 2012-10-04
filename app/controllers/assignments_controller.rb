
# controller for assignments

class AssignmentsController < ApplicationController
  
  # check if the user is logged in before any actions
  before_filter :check_login
  # checks CanCan abilities
  authorize_resource

  def index
    # retrieves all of the current assignments in the system (paginates list)
    # orders them alphabetically by store name
    @assignments_current = Assignment.by_store.by_employee.current.paginate(:page => params[:current_page]).per_page(10)
    # retrieves all of the past assignments in the system (paginates list)
    # orders them alphabetically by store name
    @assignments_past = Assignment.by_store.by_employee.past.paginate(:page => params[:past_page]).per_page(10)
  end

  def show
    # retrieves the assignmnet with the parameter specified
    @assignment = Assignment.find(params[:id])
    # retrieves the completed shifts associated with the assignment
    @shifts = Shift.for_assignment(@assignment.id).completed.paginate(:page => params[:page]).per_page(5)
  end

  def new
    # retrieves a new assignment
    @assignment = Assignment.new
    # give assignment store_id params if known to populate form
    @assignment.store_id = params[:store_id]
  end

  def edit
    # retrieves the assignment to edit
    @assignment = Assignment.find(params[:id])
  end

  def create
    # retrieves the assignment to create
    @assignment = Assignment.new(params[:assignment])
    # convert the start date to a saveable date
    @assignment.start_date = convert_to_date(params[:assignment][:start_date])
        
    if @assignment.save  # if saved to the database
      # flash notice that it was saved
      flash[:notice] = "Successfully created assignment."
      redirect_to @assignment # go to assignment 'show' page
    else # if the assignment was not saved
      # stay at the 'new' form
      render :action => 'new'
    end

  end

  def update
    # retrieves the assignment to update
    @assignment = Assignment.find(params[:id])
    # convert the start date to a saveable time
    @assignment.start_date = convert_to_date(params[:assignment][:start_date])
    
    # if the assignment was updated
    if @assignment.save
      # flash notice that says it was updated
      flash[:notice] = "Successfully updated assignment."
      redirect_to @assignment  # go to the assignment 'show' page
    else  # if the assignment was not updated
      # stay at the 'edit' form
      render :action => 'edit'
    end
    
  end

  def destroy
    # retrieve the assignment to be destroyed
    @assignment = Assignment.find(params[:id])
    @assignment.destroy  # destroy the assignment

    # flash a notice that says the assignment was removed
    flash[:notice] = "Successfully removed assignment from the system."
    # go to the assignments index page
    redirect_to assignments_url
  end
end
