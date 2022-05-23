BULK_UPLOAD_ZIPFILE_DEFAULT_ROOT_DIRECTORY = if !ENV.fetch("BULK_UPLOAD_ZIPFILE_DIR", "").empty?
                                               ENV["BULK_UPLOAD_ZIPFILE_DIR"]
                                             elsif Rails.env.test?
                                               Rails.root.join("tmp/test/bulk-upload-zip-file-tmp")
                                             else
                                               Rails.root.join("bulk-upload-zip-file-tmp")
                                             end

FileUtils.mkdir_p(BULK_UPLOAD_ZIPFILE_DEFAULT_ROOT_DIRECTORY)
