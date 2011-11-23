platform = "preview" # Whitehall.platform

connection = Fog::Storage.new({
 provider: 'AWS',
 aws_secret_access_key: Whitehall.aws_secret_access_key,
 aws_access_key_id: Whitehall.aws_access_key_id,
 region: 'eu-west-1'
})

directory = connection.directories.detect do |d|
  d.key == "whitehall-frontend-#{platform}"
end

Attachment.all.each do |attachment|
  file = directory.files.head(attachment.file.path)
  next unless file.present?

  if attachment.content_type.blank?
    attachment.content_type = "application/pdf"
  end
  if attachment.file_size.blank?
    attachment.file_size = file.content_length
  end
  attachment.save!
end
