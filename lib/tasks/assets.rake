# Maintain Rails < 7 behaviour of running yarn:install before assets:precompile

require "sprockets/rails/task"
Sprockets::Rails::Task.new(Rails.application) do |t|
  t.log_level = Logger::WARN
end

Rake::Task["assets:precompile"].enhance(["yarn:install"]).enhance(["dartsass:build"])
