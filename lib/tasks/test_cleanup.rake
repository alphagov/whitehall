namespace :test do
  desc "Remove temporary 'uploaded' files from the filesystem"
  task :cleanup => :environment do
    puts "Removing temporary uploaded files."
    Dir.glob(Rails.root.join('tmp/test/env*/*uploads/system')).each do |uploads_folder|
      FileUtils.rm_rf(uploads_folder)
    end
    FileUtils.rm_rf Rails.root.join('tmp/test-bulk-upload-zip-file-tmp')
  end
end

task :default => "test:cleanup"
