# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Our test suite generates ~17MB of logs at log level :info, switching
# to log level :warn reduces logging and increases execution speed.
ENV["LOG_LEVEL"] = "warn"

require File.expand_path("config/application", __dir__)
require "ci/reporter/rake/minitest" if Rails.env.test?

begin
  require "pact/tasks"
rescue LoadError
  # Pact isn't available in all environments
end

Whitehall::Application.load_tasks

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint test pact:verify]
