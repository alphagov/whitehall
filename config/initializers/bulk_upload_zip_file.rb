BULK_UPLOAD_ZIPFILE_DEFAULT_ROOT_DIRECTORY = if Rails.env.test?
                                               Rails.root.join('tmp/test/bulk-upload-zip-file-tmp')
                                             else
                                               Rails.root.join('bulk-upload-zip-file-tmp')
                                             end

begin
  FileUtils.mkdir_p(BULK_UPLOAD_ZIPFILE_DEFAULT_ROOT_DIRECTORY)
rescue Errno::EEXIST
  puts "#{BULK_UPLOAD_ZIPFILE_DEFAULT_ROOT_DIRECTORY} exists"
end
