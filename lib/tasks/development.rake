namespace :development do
  desc "Move uploaded files from incoming to clean, faking a virus scan"
  task fake_virus_scan: :environment do
    puts "Moving incoming uploads to simulate a virus scan:"
    file_paths = Dir.glob(Whitehall.incoming_uploads_root + '/**/*')
    file_paths.each { |file_path| puts file_path }

    FileUtils.cp_r(Whitehall.incoming_uploads_root + '/.', Whitehall.clean_uploads_root + "/")
    FileUtils.rm_r(Whitehall.incoming_uploads_root + '/system') if File.exist?(Whitehall.incoming_uploads_root + '/system')
    puts "#{file_paths.size} files/folders moved to clean-uploads"
  end

  task :change_attachment, %i[attachment_id path_to_file] => :environment do |_task, args|
    puts "reading file"
    file = File.open(args[:path_to_file], "rb")
    attachment_data = AttachmentData.create(file: file)
    puts "uploading attachment"
    Attachment.find(args[:attachment_id]).update_attribute(:attachment_data_id, attachment_data.id)
    puts "file attached successfully"
  end
end
