total_processed = 0

Edition.in_pre_publication_state.find_each(batch_size: 1000) do |edition|
  edition.set_slug
  total_processed += 1 if edition.update_columns(
    slug: edition.slug,
    slug_from_title: edition.slug_from_title,
    touch: false,
  )

  puts "Processed #{total_processed} editions" if (total_processed % 5000).zero?
end

puts "Total editions processed: #{total_processed}"
