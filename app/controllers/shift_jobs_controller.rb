# controller for shift_jobs

class ShiftJobsController < ApplicationController

  # check if the user is logged in before any actions
  before_filter :check_login
  # checks CanCan abilities
  authorize_resource

  def index
  end
  
  def show
  end

  def new
    # instantiates a new shift_job
    @shift_job = ShiftJob.new
    # gets all teh active jobs in alphabetical order
    # used for multi-model form with shifts
    @jobs = Job.alphabetical.active
  end

  def edit
    # retrieves the shift_job to edit
    @shift_job = ShiftJob.find(params[:id])
  end

  def create
    # creates a new shift_job
    @shift_job = ShiftJob.new(params[:shift_job])
  end

  def update
    #retrieves the shift_job to update
    @shift_job = ShiftJob.find(params[:id])
  end

  def destroy
    # retrieves the shift_job to destroy
    @shift_job = ShiftJob.find(params[:id])
    # detroys that shift_job
    @shift_job.destroy
  end
end
