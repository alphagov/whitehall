# Documents with non existent statistical_data_sets
doc_ids = [53_956, 64_993, 65_089, 72_821]
non_existent_data_sets = Document.where(id: [71_831, 71_833])

doc_ids.each do |doc_id|
  d = Document.find(doc_id)
  e = d.live_edition
  e.statistical_data_sets = (e.statistical_data_sets - non_existent_data_sets)
  e.save!
end
