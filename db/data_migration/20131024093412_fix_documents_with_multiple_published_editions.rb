puts "Re-archiving previous editions on documents with more than one published edition"

dodgy_documents = Edition.published.group(:document_id).having("count(*)>1").collect(&:document).uniq
puts "#{dodgy_documents.count} document(s) found with multiple published editions:"
puts '----------------------'
dodgy_documents.each do |document|
  latest_published_edition = document.editions.published.order(:public_timestamp).last
  puts "#{latest_published_edition.id} #{latest_published_edition.title} (#{latest_published_edition.created_at})"
  puts "\t#{document.editions.published.count} published editions - archiving outdated ones."
  latest_published_edition.archive_previous_editions
end

dodgy_docs_count_after = Edition.published.group(:document_id).having("count(*)>1").collect(&:document).uniq.count
if dodgy_docs_count_after == 0
  puts "Script completed successfully. 0 documents found with multiple publised editions"
else
  puts "Error: #{dodgy_docs_count_after} documents found with multiple published editions"
end
