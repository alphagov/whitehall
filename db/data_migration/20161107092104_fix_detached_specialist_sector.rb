linkable_topics = LinkableTopics.new

linkable_topic_items = linkable_topics.send(:fetch_topics_from_publishing_api)
linkable_topic_items = linkable_topics.send(:change_separator, linkable_topic_items)
linkable_topic_items = linkable_topics.send(:select_only_subtopics, linkable_topic_items)

specialist_sectors = SpecialistSector.where(topic_content_id: nil)

puts 'Found %<count>d Specialist Sectors with a missing `topic_content_id`' %
  { count: specialist_sectors.count }

specialist_sectors.each do |specialist_sector|
  puts '- Processing %<specialist_sector>s' % { specialist_sector: specialist_sector.inspect }

  if (topic = linkable_topic_items.find { |item| item['base_path'] == "/topic/#{specialist_sector['tag']}" })
    puts '  Found topic %<topic>s' % { topic: topic.inspect }
    puts '  %<status>s `content_id` %<content_id>s' %
      { content_id: specialist_sector.topic_content_id = topic['content_id'],
        status: specialist_sector.save ? 'Assigned' : 'Failed to assign' }
  else
    puts '  No topic found'
  end
end
