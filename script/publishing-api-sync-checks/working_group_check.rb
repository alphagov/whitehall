# Working Groups are called PolicyGroup in the code as they have been partially
# renamed
working_groups = PolicyGroup.all
check = DataHygiene::PublishingApiSyncCheck.new(working_groups)

check.add_expectation("format") do |content_store_payload, _|
  content_store_payload["format"] == "working_group"
end
check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == record.search_link
end
check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.name
end

check.perform
