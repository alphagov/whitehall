require_relative "../../app/validators/gov_uk_url_validator"

desc "Create a draft document collection in the whitehall database, from a given specialist topic"
task :create_draft_document_collection, %i[specialist_topic_base_path assignee_email_address] => :environment do |_task, args|
  message = "Error! A specialist topic base_path and valid email address are required"
  raise message unless args[:specialist_topic_base_path].present? && args[:assignee_email_address].present?

  puts "Fetching specialist topic at #{args[:specialist_topic_base_path]}"
  topic = SpecialistTopicFetcher.call(args[:specialist_topic_base_path])

  puts "Creating draft document collection"
  builder = DraftDocumentCollectionBuilder.new(topic, args[:assignee_email_address])
  builder.perform!

  puts builder.message
end
