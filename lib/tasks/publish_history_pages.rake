namespace :history_pages do
  desc "Publish history pages to the publishing API"
  task publish: :environment do
    Dir[Rails.root.join("lib/history_pages/*.yaml")].each do |file_path|
      puts "Publishing #{file_path}"

      history_page_yaml = YAML.load(File.read(file_path))
      PublishHistoryPage.call(history_page_yaml)
    end
  end
end
