# This file is overwritten on deploy
#
Airbrake.configure do |config|
  # Adding production to the development environments causes Airbrake not
  # to attempt to send notifications.
  config.development_environments << "production"
end
