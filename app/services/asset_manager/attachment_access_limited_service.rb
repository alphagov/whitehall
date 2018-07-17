module AssetManager
  class AttachmentAccessLimitedService
    def initialize(attachment_data)
      @attachment_data = attachment_data
    end

    def call
      access_limited_to_these_users = []
      if attachment_data.access_limited?
        access_limited_to_these_users = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
      end

      enqueue_job(attachment_data, attachment_data.file, access_limited_to_these_users)
      if attachment_data.pdf?
        enqueue_job(attachment_data, attachment_data.file.thumbnail, access_limited_to_these_users)
      end
    end

    def self.call(*args)
      new(*args).call
    end

    private_class_method :new

  private

    attr_reader :attachment_data

    def enqueue_job(uploader, access_limited_to_these_users)
      legacy_url_path = uploader.asset_manager_path
      AssetManagerUpdateAssetWorker.new.perform(attachment_data, legacy_url_path, "access_limited" => access_limited_to_these_users)
    end
  end
end
