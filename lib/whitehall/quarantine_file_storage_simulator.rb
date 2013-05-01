module Whitehall
  module QuarantineFileStorageSimulator
    def self.enable
      FileUtils.mkdir_p Rails.root.join("test-quarantine")
      if File.exists?(Rails.root.join('public/government/uploads'))
        FileUtils.mv Rails.root.join('public/government/uploads').to_s, Rails.root.join('public/government/original-uploads').to_s
      end
      FileUtils.mkdir_p Rails.root.join("public/government/uploads")

      FileUtils.mkdir_p Rails.root.join("test-clean")
      Whitehall.stubs(:clean_upload_path).returns(Rails.root.join('test-clean'))

      CarrierWave.configure do |config|
        config.reset_config
        config.storage Whitehall::QuarantinedFileStorage
        config.incoming_root Rails.root + "test-quarantine"
        config.clean_root Rails.root + "public/government/uploads"
      end

      yield

    ensure
      FileUtils.rm_rf Rails.root.join("test-clean")

      FileUtils.rm_rf(CarrierWave::Uploader::Base.incoming_root)
      FileUtils.rm_rf(CarrierWave::Uploader::Base.clean_root)
      if File.exists?(Rails.root.join('public/government/original-uploads'))
        FileUtils.mv Rails.root.join('public/government/original-uploads').to_s, Rails.root.join('public/government/uploads').to_s
      end

      CarrierWave::Uploader::Base.reset_config
      load Rails.root + 'config/initializers/carrierwave.rb'
    end
  end
end
