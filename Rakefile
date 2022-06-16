# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Our test suite generates ~17MB of logs at log level :info, switching
# to log level :warn reduces logging and increases execution speed.
ENV["LOG_LEVEL"] = "warn"
# We only set this var when running via Rake, so that we can get
# sensible coverage reports when running a full test suite,
# without overwriting them when we're just running a single test
ENV["COVERAGE"] = "true"

require File.expand_path("config/application", __dir__)
require "ci/reporter/rake/minitest" if Rails.env.test?

begin
  require "pact/tasks"
rescue LoadError
  # Pact isn't available in all environments
end

Whitehall::Application.load_tasks

# no-op task to ease removal of shared mustache, to be removed once dependents are amended.
namespace :shared_mustache do
  desc "[Temporary] A task that does nothing for any denpendent tools that call this"
  task compile: :environment do
    puts "This application no longer depends on shared_mustache and there is no further need to call this task"
  end
end

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint test assets:precompile cucumber jasmine pact:verify]
