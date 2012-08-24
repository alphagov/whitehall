#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# At the time of committing, our full test suite generated 17MB of logs.  Disabling logging
# decreased the time taken to run all tests by around 20 seconds on my machine.
ENV["DISABLE_LOGGING_IN_TEST"] = "true"

require File.expand_path('../config/application', __FILE__)
require 'ci/reporter/rake/minitest' if Rails.env.development? or Rails.env.test?

Whitehall::Application.load_tasks
