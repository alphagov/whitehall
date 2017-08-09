Airbrake.configure do |config|
  if ENV['ERRBIT_API_KEY'].present?
    errbit_uri = Plek.find_uri('errbit')
    config.project_key = ENV['ERRBIT_API_KEY']
    config.project_id  = ENV['ERRBIT_API_KEY']
    config.host        = errbit_uri
    config.environment = ENV['ERRBIT_ENVIRONMENT_NAME']
  else
    # Setting the environment and adding it to ignore_environments causes
    # Airbrake not to attempt to send notifications.
    config.environment = 'development'
    config.ignore_environments << 'development'
  end
end
