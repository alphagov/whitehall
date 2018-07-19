class AssetManager::AttachmentAccessLimitedUpdater
  def initialize(attachment_data)
    @attachment_data = attachment_data
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    access_limited_to_these_users = []
    if attachment_data.access_limited?
      access_limited_to_these_users = AssetManagerAccessLimitation.for(attachment_data.access_limited_object)
    end

    update_asset(attachment_data, attachment_data.file, access_limited_to_these_users)
    if attachment_data.pdf?
      update_asset(attachment_data, attachment_data.file.thumbnail, access_limited_to_these_users)
    end
  end

  private_class_method :new

private

  attr_reader :attachment_data

  def update_asset(attachment_data, uploader, access_limited_to_these_users)
    AssetManager::AssetUpdater.call(
      attachment_data,
      uploader.asset_manager_path,
      "access_limited" => access_limited_to_these_users,
    )
  end
end
