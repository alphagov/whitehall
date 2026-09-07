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

# Defining an explicit list, since models like Consultation response form data
# also includes AssetData but can't run generically like Attachment/Image.
def for_each_asset_data_type(&block)
  %w[AttachmentData ImageData].each(&block)
end
