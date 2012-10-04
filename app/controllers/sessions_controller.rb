class SessionsController < ApplicationController
  def new
  end
  
  def create
    # finds the user by email
    user = User.find_by_email(params[:email])
    # checks if the user has entered the correct password
    if user && user.authenticate(params[:password])
      # sets the session user_id
      session[:user_id] = user.id
      # tells the user they are logged in
      redirect_to home_path, notice: "Logged in!"
    else # there is an error
      # let the user know
      flash.now.alert = "Email or password is invalid"
      render "new"
    end
  end
  
  def destroy
    # ends the user's session
    session[:user_id] = nil
    # tells the user they are logged out
    redirect_to home_path, notice: "Logged out!"
  end
end