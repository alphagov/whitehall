require "govuk_app_config/govuk_unicorn"
GovukUnicorn.configure(self)

working_directory File.dirname(File.dirname(__FILE__))

# Preload the entire app
preload_app true

before_fork do |_server, _worker|
  # The following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection.
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  # Force translations to be loaded into memory.
  I18n.t('activerecord')
end

after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
