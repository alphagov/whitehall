class Whitehall::AssetManagerAndQuarantinedFileStorage < CarrierWave::Storage::Abstract
  def store!(file)
    asset_manager_file = Whitehall::AssetManagerStorage.new(uploader).store!(file)
    quarantined_file = Whitehall::QuarantinedFileStorage.new(uploader).store!(file)

    File.new(asset_manager_file, quarantined_file)
  end

  def retrieve!(identifier)
    asset_manager_file = Whitehall::AssetManagerStorage.new(uploader).retrieve!(identifier)
    quarantined_file = Whitehall::QuarantinedFileStorage.new(uploader).retrieve!(identifier)

    File.new(asset_manager_file, quarantined_file)
  end

  class File
    delegate :path, :content_type, :filename, :size, to: :@quarantined_file

    def initialize(asset_manager_file, quarantined_file)
      @asset_manager_file = asset_manager_file
      @quarantined_file = quarantined_file
    end

    def url
      @quarantined_file.url
    end

    def asset_manager_path
      @asset_manager_file.path
    end

    def delete
      @quarantined_file.delete
      @asset_manager_file.delete
    end

    def zero_size?
      @asset_manager_file.zero_size?
    end
  end
end
