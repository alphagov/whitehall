# Load the system-wide standard Unicorn file
def load_file_if_exists(config, file)
  config.instance_eval(File.read(file)) if File.exist?(file)
end
load_file_if_exists(self, "/etc/govuk/unicorn.rb")
working_directory File.dirname(File.dirname(__FILE__))
worker_processes 4

# Preload the entire app
preload_app true

before_fork do |_, _|
  # The following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection.
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  # Force translations to be loaded into memory.
  I18n.t('activerecord')
end

after_fork do |_, _|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
