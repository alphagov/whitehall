namespace :development do
  task :change_attachment, %i[attachment_id path_to_file] => :environment do |_task, args|
    puts "reading file"
    file = File.open(args[:path_to_file], "rb")
    attachment_data = AttachmentData.create(file: file)
    puts "uploading attachment"
    Attachment.find(args[:attachment_id]).update_attribute(:attachment_data_id, attachment_data.id)
    puts "file attached successfully"
  end
end
