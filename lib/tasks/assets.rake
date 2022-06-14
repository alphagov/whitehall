# Maintain Rails < 7 behaviour of running yarn:install before assets:precompile
Rake::Task["assets:precompile"].enhance(["yarn:install"])

# Compiles shared Mustache templates when running assets:precompile
Rake::Task["assets:precompile"].enhance(["shared_mustache:compile"])
