Airbrake.configure do |config|
  if ENV.has_key?("ERRBIT_API_KEY")
    config.api_key          = ENV["ERRBIT_API_KEY"]
    config.host             = "errbit.#{ENV['GOVUK_APP_DOMAIN']}"
    config.secure           = true
    config.environment_name = ENV['ERRBIT_ENVIRONMENT_NAME']
  else
    # Adding production to the development environments causes Airbrake not
    # to attempt to send notifications.
    config.development_environments << "production"
  end
end
