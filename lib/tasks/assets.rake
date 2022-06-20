# Maintain Rails < 7 behaviour of running yarn:install before assets:precompile
Rake::Task["assets:precompile"].enhance(["yarn:install"])
