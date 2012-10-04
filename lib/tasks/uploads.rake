namespace :whitehall do
  namespace :uploads do
    task :import_from_s3 => :environment do
      require 'fileutils'

      storage = Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: Whitehall.aws_access_key_id,
        aws_secret_access_key: Whitehall.aws_secret_access_key,
        region: 'eu-west-1'
      )

      directory = storage.directories.get("whitehall-frontend-#{Whitehall.platform}")

      directory.files.each_with_index do |s3_file, ix|
        destination = Rails.root + "incoming-uploads" + s3_file.key
        FileUtils.mkdir_p File.dirname(destination)
        File.open(destination, 'wb') do |local_file|
          local_file.write(s3_file.body)
        end
        if ix % 100 == 0
          puts "Imported #{ix} files so far..."
        end
      end
      puts "Done."
    end
  end
end