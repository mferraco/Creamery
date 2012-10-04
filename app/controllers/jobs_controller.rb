# controller for jobs

class JobsController < ApplicationController
  
  # check if user is logged in before any actions
  before_filter :check_login
  # checks CanCan abilities
  authorize_resource

  def index
    # retrieves all the jobs in alphabetical order
    @jobs_active = Job.active.alphabetical.paginate(:page => params[:active]).per_page(10)
    @jobs_inactive = Job.inactive.alphabetical.paginate(:page => params[:inactive]).per_page(10)
  end
  
  def show
    # retrieves the job to show
    @job = Job.find(params[:id])
  end

  def new
    # instantiates a new job
    @job = Job.new
  end

  def edit
    # retrieves the job to edit
    @job = Job.find(params[:id])
  end

  def create
    # creates a new job
    @job = Job.new(params[:job])
    
    # save that job to the database
    if @job.save
      # if saved to database
      flash[:notice] = "Job has been created."
      redirect_to @job # go to show job page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    # retrieves the job to update
    @job = Job.find(params[:id])
    
    # updates that job's attributes
    if @job.update_attributes(params[:job])
      flash[:notice] = "Job has been updated."
      redirect_to @job
    else
      render :action => 'edit'
    end
  end

  def destroy
    # retrieves the job to destroy
    @job = Job.find(params[:id])
    # destroys that job
    @job.destroy
    
    flash[:notice] = "Successfully removed the job."
    redirect_to jobs_url
  end
end
