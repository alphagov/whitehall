Attachment.all.each do |attachment|
  puts attachment.file
  attachment.file.recreate_versions!
  puts "done"
end

