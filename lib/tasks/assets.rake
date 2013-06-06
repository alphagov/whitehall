# This has been taken wholesale from https://gist.github.com/sj26/4728657

# Stick this in lib/tasks/assets.rake or similar
#
# A bug was introduced in rails in 7f1a666d causing the whole application cache
# to be cleared everytime a precompile is run, but it is not neccesary and just
# slows down precompiling.
#
# Secondary consequences are the clearing of the whole cache, which if using
# the default file cache could cause an application level performance hit.
#
# This is already fixed in sprockets-rails for rails 4, but we patch here for
# interim gains.
#
# If you're using rails pre-3.2 change "primary" to "digest" below.

Rake::Task["assets:precompile:primary"].prerequisites.delete "tmp:cache:clear"
Rake::Task["assets:precompile:nondigest"].prerequisites.delete "tmp:cache:clear"
