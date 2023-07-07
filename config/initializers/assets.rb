# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Add project root to the asset load path so we can load block-editor assets.
# e.g. by using path "block-editor/dist/block-editor"
Rails.application.config.assets.paths << Rails.root
