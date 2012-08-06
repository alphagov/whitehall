default_unicorn_config_file = "/etc/govuk/unicorn.rb"
load(default_unicorn_config_file) if File.exist?(default_unicorn_config_file)
working_directory File.dirname(File.dirname(__FILE__))
worker_processes 4