def load_file_if_exists(config, file)
  config.instance_eval(File.read(file)) if File.exist?(file)
end
load_file_if_exists(self, "/etc/govuk/unicorn.rb")
working_directory File.dirname(File.dirname(__FILE__))
worker_processes 4

if env == 'production'
  # We want to preload the entire app in production mode
  preload_app true

  before_fork do |server, worker|
    # the following is highly recomended for Rails + "preload_app true"
    # as there's no need for the master process to hold a connection
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.connection.disconnect!
    end
  end

  after_fork do |server, worker|
    # the following is *required* for Rails + "preload_app true",
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
    end
  end
end
