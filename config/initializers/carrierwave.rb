require "pathname"
require "carrier_wave/sanitized_file"

Whitehall::Application.config.to_prepare do
  CarrierWave.configure do |config|
    config.storage Storage::DefaultStorage
    config.enable_processing = false if Rails.env.test?
    uploads_root = if ENV["GOVUK_UPLOADS_ROOT"].present?
                     Pathname.new(ENV["GOVUK_UPLOADS_ROOT"])
                   else
                     Rails.root
                   end
    config.cache_dir = uploads_root.join "carrierwave-tmp"
    config.cache_storage = :file
    config.validate_integrity = false
    config.validate_processing = false
  end
end
