require "benchmark"

# Takes the existing data that joins document series to editions and creates
# the corresponding joins to link series directly with documents instead.

time = Benchmark.measure do
  # results will contain an array of hashes mapping document series to document ids in the form:
  # { 'document_series_id' => 123, 'id' => '456'} where id is the document id.
  query = EditionDocumentSeries.joins(edition: :document)
                               .where("editions.state != 'deleted'")
                               .select(['document_series_id', 'documents.id'])
                               .order('editions.publication_date DESC')
  results = ActiveRecord::Base.connection.select_all(query)

  # We are only interested in unique combinations of document to series mappings
  unique_results = results.uniq
  unique_series_count = results.map {|r| r['document_series_id'] }.uniq.count

  puts "Found #{unique_results.count} documents across #{unique_series_count} document series"
  puts "Creating new joins between document series and documents"

  unique_results.each do |row|
    DocumentSeriesMembership.where(document_series_id: row['document_series_id'], document_id: row['id']).first_or_create!
    print '.'
  end
end

puts "\nAll done. Total time taken:"
puts time
