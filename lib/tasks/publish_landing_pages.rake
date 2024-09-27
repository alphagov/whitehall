# NOTE: Temporary while we work out which
#       publishing app / CMS to use for landing pages
namespace :landing_pages do
  desc "Publish landing pages to the publishing API"
  task publish: :environment do
    Dir[Rails.root.join("lib/landing_pages/*.json")].each do |file_path|
      puts "Publishing #{file_path}"

      content_item = JSON.parse(File.read(file_path))
      PublishLandingPage.call(content_item)
    end
  end
end
