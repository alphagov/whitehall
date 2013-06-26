BulkUpload::ZipFile.default_root_directory = if Rails.env.test?
  Rails.root.join('tmp/test/bulk-upload-zip-file-tmp')
else
  Rails.root.join('bulk-upload-zip-file-tmp')
end
