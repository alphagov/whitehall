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

begin
  require "pact/tasks"
rescue LoadError
  # Pact isn't available in all environments
end

desc "Run the 'pact verify' command with the RSpec 'progress' formatter"
task "pact:verify:with_progress_formatter" => :environment do
  sh "pact verify --format progress --pact-helper spec/service_consumers/pact_helper.rb"
end

Whitehall::Application.load_tasks

Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task default: %i[lint test cucumber jasmine pact:verify:with_progress_formatter]
