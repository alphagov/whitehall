namespace :finders do
  desc "Publish finder pages to the publishing API"
  task publish: :environment do
    Dir[Rails.root.join("lib/finders/*.json")].each do |file_path|
      puts "Publishing #{file_path}"

      content_item = JSON.parse(File.read(file_path))
      PublishFinder.call(content_item)
    end
  end

  desc "Temporary task to unpublish non-English finders - this can be removed after running in production"
  task temp_unpublish_non_english_finders: :environment do
    announcements_finder_content_id = "88936763-df8a-441f-8b96-9ea0dc0758a1"
    publications_finder_content_id = "b13317e9-3753-47b2-95da-c173071e621d"

    locales = Locale.non_english.map(&:code)

    locales.each do |locale|
      puts "Publishing content item for /government/announcements.#{locale}"
      publish_finder_for_locale(announcements_finder_content_id, "/government/announcements.#{locale}", locale)

      puts "Unpublishing /government/announcements.#{locale}"
      Whitehall::PublishingApi.publish_gone_async(announcements_finder_content_id, nil, nil, locale.to_s)

      puts "Publishing content item for /government/publications.#{locale}"
      publish_finder_for_locale(publications_finder_content_id, "/government/publications.#{locale}", locale)

      puts "Unpublishing /government/publications.#{locale}"
      Whitehall::PublishingApi.publish_gone_async(publications_finder_content_id, nil, nil, locale.to_s)
    end
  end
end

def publish_finder_for_locale(content_id, base_path, locale)
  finder_content_item = {
    base_path:,
    document_type: "finder",
    locale: locale.to_s,
    publishing_app: "whitehall",
    rendering_app: "whitehall-frontend",
    schema_name: "placeholder",
    title: "Placeholder",
    details: {},
    update_type: "major",
    routes: [
      {
        type: "exact",
        path: base_path,
      },
      {
        type: "exact",
        path: "#{base_path}.atom",
      },
      {
        type: "exact",
        path: "#{base_path}.json",
      },
    ],
  }

  Services.publishing_api.put_content(
    content_id,
    finder_content_item,
  )

  Services.publishing_api.publish(content_id, nil, locale:)
end
