task extract_attachment_data: :environment do
  puts "Extracting #{AttachmentData.count} files"
  AttachmentData.find_each do |file|
    file.extract_text
  end
end
