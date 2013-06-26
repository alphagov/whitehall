namespace :test do
  desc "Remove any files uploaded during test run"
  task :cleanup => :environment do
    puts "Removing all uploaded files created during test run..."
    Dir.glob(Rails.root.join('tmp/test/env*/*uploads/system')).each do |uploads_folder|
      FileUtils.rm_rf(uploads_folder)
    end
    FileUtils.rm_rf Rails.root.join('tmp/test/bulk-upload-zip-file-tmp')
  end
end

task :default => "test:cleanup"
