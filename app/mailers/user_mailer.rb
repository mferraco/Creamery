class UserMailer < ActionMailer::Base
  # email will come from this email
  default from: '<your email here>'
  
  # creates a new message to send to the user
  def new_user_message(user)
    @user = user
    mail(:to => @user.email, :subject => "New Employee Account Created at A&M Creamery")
  end
end
