namespace :test do
  desc "Remove temporary 'uploaded' files from the filesystem"
  task :cleanup => :environment do
    puts "Removing temporary uploaded files."
    FileUtils.rm_rf(Whitehall.incoming_uploads_root + '/system')
    FileUtils.rm_rf(Whitehall.clean_uploads_root + '/system')
    FileUtils.rm_rf Rails.root.join('tmp/test-bulk-upload-zip-file-tmp')
  end
end

task :default => "test:cleanup"
