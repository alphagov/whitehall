def log(message)
  puts message
end

def exit_with_usage_message
  puts "Usage: script/rails r #{__FILE__} /path/to/download/directory"
  exit 1
end

def upload_attachment(attachment_path, metadata_path)
  metadata = ActiveSupport::JSON.decode(File.read(metadata_path))

  edition_attachment = EditionAttachment.new(
    edition_id: metadata["publication_id"],
    attachment_attributes: {
      file: File.open(attachment_path),
      title: metadata["title"],
      order_url: metadata["order_url"],
      price: metadata["price"],
      unique_reference: metadata["unique_reference"]
    }
  )
  if edition_attachment.save
    log "\tAdded attachment data from #{attachment_path}"
    exit(0)
  else
    log "\tCouldn't save attachment: #{edition_attachment.errors.full_messages}"
    exit(1)
  end
end

if __FILE__ == $0
  attachment_path = ARGV.shift
  exit_with_usage_message unless attachment_path
  metadata_path = ARGV.shift
  exit_with_usage_message unless metadata_path

  upload_attachment(attachment_path, metadata_path)
end
