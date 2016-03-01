case_studies = CaseStudy.latest_published_edition
check = DataHygiene::PublishingApiSyncCheck.new(case_studies)

check.add_expectation("format") do |content_store_payload, _|
  content_store_payload["format"] == "case_study"
end
check.add_expectation("base_path") do |content_store_payload, record|
  content_store_payload["base_path"] == record.search_link
end
check.add_expectation("title") do |content_store_payload, record|
  content_store_payload["title"] == record.title
end

check.perform
