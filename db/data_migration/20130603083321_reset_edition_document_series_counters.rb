counts = EditionDocumentSeries.group(:edition_id).count
puts "Reseting the document_series_count on #{counts.size} Editions."

counts.each do |edition_id, count|
  ActiveRecord::Base.connection.execute("UPDATE editions SET document_series_count=#{count} WHERE id=#{edition_id}")
end
