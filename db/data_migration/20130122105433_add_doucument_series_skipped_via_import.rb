require 'csv'


total_docs = 0
csv_with_ds = 0
document_series_added = 0
document_series_exisiting = 0
total_doc_series = 0
could_not_find = []

CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8").each do |row|
  attributes = row.to_hash
  ds = DocumentSource.find_by_url(attributes["old_url"])
  if ds
    total_docs += 1
    edition = ds.document.editions.latest_edition.first
    if attributes["document_series_1"].present? && edition.can_be_grouped_in_series?
      csv_with_ds += 1
      document_series = DocumentSeries.find_by_slug(attributes["document_series_1"])
      if document_series
        eds = EditionDocumentSeries.new(edition: edition, document_series: document_series)
        if eds.valid?
          eds.save
          document_series_added += 1
        else
          document_series_exisiting += 1
        end
      else
        could_not_find << attributes["document_series_1"]
      end
    elsif attributes["document_series_1"].present?
      csv_with_ds += 1
    end
  end
end

if could_not_find.any?
  p "The following document series could not be found and we are ignoring:"
  require 'pp'
  pp could_not_find
end

p "Found #{total_docs} documents, with #{csv_with_ds} rows containing \
document_series_1 and #{document_series_added} were added while \
#{document_series_exisiting} were already created"
