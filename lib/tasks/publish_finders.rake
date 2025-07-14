namespace :finders do
  desc "Publish finder pages to the publishing API"
  task publish: :environment do
    Dir[Rails.root.join("lib/finders/*.json")].each do |file_path|
      puts "Publishing #{file_path}"

      content_item = JSON.parse(File.read(file_path))
      PublishFinder.call(content_item)
    end
  end

  desc "Publish a single finder page (by filename) to the publishing API"
  task :publish_one, %i[filename] => [:environment] do |_, args|
    filename = args.fetch(:filename)
    content_item = JSON.load_file(Rails.root.join("lib/finders/#{filename}"))
    puts "Publishing #{filename}"
    PublishFinder.call(content_item)
  end
end
