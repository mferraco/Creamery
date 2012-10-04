# all controllers inherit from ApplicationController

class ApplicationController < ActionController::Base
  # include the DateFormatter module to get its methods
  include DateFormatter
  # use this is encrypt passwords and aid authentication
  protect_from_forgery
  
  # gets the current user of the system
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
  
  # check if the user is logged in
  def logged_in?
    current_user
  end
  helper_method :logged_in?
  
  # if not logged in let them know
  def check_login
    redirect_to login_url, alert: "You need to log in to view this page." if current_user.nil?
  end
  
  # error to replace the CanCan default error
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You are not authorized to view this page."
    redirect_to(login_path)
  end
  
end
