namespace :test do
  desc "Remove any files uploaded during test run"
  task cleanup: :environment do
    puts "Removing all uploaded files created during test run..."
    Dir.glob(Rails.root.join("tmp/test/env*/*uploads/system")).each do |uploads_folder|
      FileUtils.rm_rf(uploads_folder)
    end
  end
end

task default: "test:cleanup"
