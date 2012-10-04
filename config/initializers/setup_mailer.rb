# sets up the mailer with default settings
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :user_name            => "<username>",
  :password             => "<password>",
  :authentication       => "plain",
  :enable_starttls_auto => true
}
