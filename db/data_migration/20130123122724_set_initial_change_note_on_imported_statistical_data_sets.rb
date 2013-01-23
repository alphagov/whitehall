# find all imports that pulled in statistical data sets then:
# - find all their imported editions (e.g. first edition for the 
#   documents pointed to by the imported document sources)
# - set the change note of those editions to "Data updated" to mean we
#   don't say "First published" as it's not true
Import.where(data_type: 'statistical_data_set').find_each do |stats_import|
  imported_editions = StatisticalDataSet.
    unscoped.
    joins(document: :document_sources).
    where(document_sources: { import_id: stats_import.id }).
    where('not exists (
      select 1 from editions e2
      where e2.id < editions.id
      and e2.document_id = editions.document_id
    )')

  StatisticalDataSet.where(id: imported_editions.map(&:id)).update_all(change_note: 'Data updated')
  puts "Updated #{imported_editions.count} Statistical Data Sets for import #{stats_import.id}"
end
