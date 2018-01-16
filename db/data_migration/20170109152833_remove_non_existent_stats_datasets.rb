# Documents with non existent statistical_data_sets
doc_ids = [53956, 64993, 65089, 72821]
non_existent_data_sets = Document.where(id: [71831, 71833])

doc_ids.each do |doc_id|
  d = Document.find(doc_id)
  e = d.published_edition
  e.statistical_data_sets = (e.statistical_data_sets - non_existent_data_sets)
  e.save!
end
