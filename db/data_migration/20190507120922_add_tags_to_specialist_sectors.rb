linkable_topics = LinkableTopics.new

linkable_topic_items = linkable_topics.send(:fetch_linkables_from_publishing_api, document_type: 'topic')
linkable_topic_items = linkable_topics.send(:change_separator, linkable_topic_items)

specialist_sectors = SpecialistSector.where(tag: nil)

puts 'Found %<count>d Specialist Sectors with a missing `tag`' %
         { count: specialist_sectors.count }

specialist_sectors.each do |specialist_sector|
  puts '- Processing %<specialist_sector>s' % { specialist_sector: specialist_sector.inspect }

  if (topic = linkable_topic_items.find { |item| item['content_id'] == specialist_sector['topic_content_id'] })
    puts '  Found topic %<topic>s' % { topic: topic.inspect }
    puts '  %<status>s `tag` %<tag>s' %
             # Remove "/topic/" from beginning of base path (but only from beginning)
             { tag: specialist_sector.tag = topic['base_path'].gsub(/\A\/topic\//, ""),
               status: specialist_sector.save ? 'Assigned' : 'Failed to assign' }
  else
    puts '  No topic found'
  end
end

puts 'Now %<count>d Specialist Sectors with a missing `tag`' %
         { count: specialist_sectors.count }
