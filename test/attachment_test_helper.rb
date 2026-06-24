def create_attachment(attachment_data:, edition:)
  case attachment_data.class.to_s
  when "AttachmentData"
    attachment_data.attachable = edition
    file_attachment = create(:file_attachment, attachable: edition, attachment_data:)
    edition.save!
    file_attachment
  when "ImageData"
    image = create(:image, edition:)
    attachment_data.images << image
    image.image_data = attachment_data
    attachment_data.save!
    image.save!
    image
  end
end

def for_each_asset_data_type(&block)
  asset_data_types = ApplicationRecord
    .descendants
    .select { |klass| klass.include?(AssetData) }
    .map(&:name)

  asset_data_types.each(&block)
end
