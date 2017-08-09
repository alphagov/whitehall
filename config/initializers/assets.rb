# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(
  admin.css
  admin-ie8.css
  admin-ie7.css
  admin-ie6.css
  frontend/base.css
  frontend/base-ie9.css
  frontend/base-ie8.css
  frontend/base-ie7.css
  frontend/base-ie6.css
  frontend/base-rtl.css
  frontend/base-rtl-ie9.css
  frontend/base-rtl-ie8.css
  frontend/base-rtl-ie7.css
  frontend/base-rtl-ie6.css
  frontend/html-publication.css
  frontend/html-publication-ie9.css
  frontend/html-publication-ie8.css
  frontend/html-publication-ie7.css
  frontend/html-publication-ie6.css
  frontend/html-publication-rtl.css
  frontend/html-publication-rtl-ie9.css
  frontend/html-publication-rtl-ie8.css
  frontend/html-publication-rtl-ie7.css
  frontend/html-publication-rtl-ie6.css
  frontend/print.css
  admin.js
  tour/tour_pano.js
)

Rails.application.config.assets.prefix = Whitehall.router_prefix + Rails.application.config.assets.prefix
