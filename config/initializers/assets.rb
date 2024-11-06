# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Add engines to the assets load path
Dir.glob(Rails.root.join("lib/engines/**/assets/*")).each do |path|
  Rails.application.config.assets.paths << path
end
