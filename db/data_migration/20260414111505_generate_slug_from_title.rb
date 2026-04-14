total_processed = 0

Edition.skip_callback(:update, :after, :republish_topical_event_to_publishing_api)
Edition.in_pre_publication_state.find_each(batch_size: 1000) do |edition|
  edition.set_slug
  total_processed += 1 if edition.save(validate: false)

  puts "Processed #{total_processed} editions" if (total_processed % 5000).zero?
end

puts "Total editions processed: #{total_processed}"
