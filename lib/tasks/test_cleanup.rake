namespace :test do
  desc "Remove temporary 'uploaded' files from the filesystem"
  task :cleanup => :environment do
    puts "Removing temporary uploaded files."
    FileUtils.rm_rf Rails.root.join('public/system')
    FileUtils.rm_rf Rails.root.join('public/uploads')
  end
end

task :default => "test:cleanup"