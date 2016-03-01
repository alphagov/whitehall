take_part_pages = TakePartPage.all
check = DataHygiene::PublishingApiSyncCheck.new(take_part_pages)

check.add_expectation("format") do |content_store_payload, _|
  content_store_payload["format"] == "take_part"
end
check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == record.search_link
end
check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.title
end

check.perform
