publications = Publication.where(state: %w{published withdrawn})

check = DataHygiene::PublishingApiSyncCheck.new(publications)

check.add_expectation("schema_name") do |content_store_payload, _|
  content_store_payload["schema_name"] == "publication"
end

check.add_expectation("document_type") do |content_store_payload, record|
  content_store_payload["document_type"] == record.display_type_key
end

check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == record.search_link
end

check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.title
end

check.perform
