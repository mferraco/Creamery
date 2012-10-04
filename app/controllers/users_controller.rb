# controller for users

class UsersController < ApplicationController
  
  # checks if the user is logged in before actions
  before_filter :check_login
  # checks CanCan abilites
  authorize_resource

  def index
    # not used
    @users = User.all
  end

  def show
    # note used
    @user = User.find(params[:id])
  end

  def new
    # instantiates a new user
    @user = User.new
  end

  def edit
    # retrieves the current user to edit
    @user = current_user
  end

  def create
    # creates a new user
    @user = User.new(params[:user])
    # sets the session user to that new user
    session[:user_id] = @user.id
    
    # saves that user to the database
    if @user.save  # if saved to the database
      # flash notice that it was saved
      redirect_to home_path # go to 'home' page
    else # if the user was not saved
      # stay at the 'new' form
      render :action => 'new'
    end

  end

  def update
    # updates the user to the current user
    @user = current_user
  end

  def destroy
    # retrieves the user to destroy
    @user = User.find(params[:id])
    # destroys that user
    @user.destroy
  end
end
