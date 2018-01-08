about_pages = AboutPage.all
check = DataHygiene::PublishingApiSyncCheck.new(about_pages)
check.override_base_path(&:search_link)

check.add_expectation("format") do |content_store_payload, _|
  content_store_payload["format"] == 'topical_event_about_page'
end
check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == record.search_link
end
check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.name
end

check.perform
