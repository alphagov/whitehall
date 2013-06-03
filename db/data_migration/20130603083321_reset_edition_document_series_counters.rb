# There is a bug in Rails 3.x that prevents us using the reset_counters method here.
# It's fixed in Rails 4 though: https://github.com/rails/rails/pull/7822
edition_ids = Set.new
EditionDocumentSeries.all.each { |eds| edition_ids << eds.edition_id }
puts "Reseting the document_series_count on #{edition_ids.size} Editions. This may take some time..."
edition_ids.each do |edition_id|
  edition = Edition.find_by_id(edition_id)
  if edition && edition.respond_to?(:document_series)
    count = edition.document_series.count
    Edition.update(edition_id, document_series_count: count)
  end
end
