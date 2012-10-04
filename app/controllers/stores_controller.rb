
# controller for stores

class StoresController < ApplicationController

  before_filter :check_login, :except => [:index, :show]
  authorize_resource

  def index
    # retrieves all of the stores in the system (paginates list)
    # orders them alphabeticalls
    @stores_active = Store.active.alphabetical.paginate(:page => params[:active]).per_page(10)
    @stores_inactive = Store.inactive.alphabetical.paginate(:page => params[:inactive]).per_page(10)
  end

  def show
    # retrieves the store with the parameter specified
    @store = Store.find(params[:id])
    # retrieves all of the assignments for that store and orders them by employee
    @assignments = @store.assignments.by_employee.current.paginate(:page => params[:page]).per_page(10)
  end

  def new
    # retrieves a new store
    @store = Store.new
  end

  def edit
    # retrieves the store to edit
    @store = Store.find(params[:id])
  end

  def create
    # retrieves the store to create
    @store = Store.new(params[:store])
    
    if @store.save  # if saved to the database
      # flash notice that it was saved
      flash[:notice] = "Successfully created #{@store.name}."
      redirect_to @store # go to store 'show' page
    else  # if the store was not saved
      # stay at the 'new' form
      render :action => 'new'
    end
    
  end

  def update
    # retrieves the store to update
    @store = Store.find(params[:id])
    
    # if the store was uppdate
    if @store.update_attributes(params[:store])
      # flash notice that says it was updated
      flash[:notice] = "Successfully updated #{@store.name}."
      redirect_to @store  # go the to the store 'show' page
    else  # if the assignment was not updated
      # stay at the edit form
      render :action => 'edit'
    end
  end

  def destroy
    # retrieve the store to be destroyed
    @store = Store.find(params[:id])
    @store.destroy  # destroy the store
    
    # flash notice that says store was destroyed
    flash[:notice] = "Successfully removed #{@store.name} from the system."
    # go to the stores index page
    redirect_to stores_url
  end
end
