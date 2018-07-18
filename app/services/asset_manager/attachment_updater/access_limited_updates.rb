class AssetManager::AttachmentUpdater::AccessLimitedUpdates
  def self.call(attachment_data)
    access_limited = []
    if attachment_data.access_limited?
      access_limited = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
    end

    Enumerator.new do |enum|
      enum.yield AssetManager::AttachmentUpdater::Update.new(
        attachment_data, attachment_data.file, access_limited: access_limited
      )

      if attachment_data.pdf?
        enum.yield AssetManager::AttachmentUpdater::Update.new(
          attachment_data, attachment_data.file.thumbnail, access_limited: access_limited
        )
      end
    end
  end
end
