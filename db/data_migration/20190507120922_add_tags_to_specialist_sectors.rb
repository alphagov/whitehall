linkable_topics = LinkableTopics.new

linkable_topic_items = linkable_topics.send(:fetch_linkables_from_publishing_api, document_type: "topic")
linkable_topic_items = linkable_topics.send(:change_separator, linkable_topic_items)

specialist_sectors = SpecialistSector.where(tag: nil)

puts format("Found %<count>d Specialist Sectors with a missing `tag`", count: specialist_sectors.count)

specialist_sectors.each do |specialist_sector|
  puts format("- Processing %<specialist_sector>s", specialist_sector: specialist_sector.inspect)

  if (topic = linkable_topic_items.find { |item| item["content_id"] == specialist_sector["topic_content_id"] })
    puts format("  Found topic %<topic>s", topic: topic.inspect)
    puts format("  %<status>s `tag` %<tag>s", tag: specialist_sector.tag = topic["base_path"].gsub(/\A\/topic\//, ""), status: specialist_sector.save ? "Assigned" : "Failed to assign")
  else
    puts "  No topic found"
  end
end

puts format("Now %<count>d Specialist Sectors with a missing `tag`", count: specialist_sectors.count)
