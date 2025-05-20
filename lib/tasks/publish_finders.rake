namespace :finders do
  desc "Publish finder pages to the publishing API"
  task publish: :environment do
    Dir[Rails.root.join("lib/finders/*.json")].each do |file_path|
      puts "Publishing #{file_path}"

      content_item = JSON.parse(File.read(file_path))
      PublishFinder.call(content_item)
    end
  end

  desc "Unpublish topical events finder to the publishing API"
  task unpublish: :environment do
    Services.publishing_api.unpublish(
      "b39c6645-c85f-44e4-b581-dbca52c59c70",
      type: "redirect",
      alternative_path: "/",
      discard_drafts: true,
    )

    puts "Finder unpublished"
  rescue GdsApi::HTTPServerError => e
    puts "Error unpublishing finder: #{e.inspect}"
  end
end
