total = Attachment.count
Attachment.all.each.with_index do |attachment, index|
  puts "Processing #{index} of #{total}"
  attachment.file.recreate_versions!
end