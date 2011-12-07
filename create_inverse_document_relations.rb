DocumentRelation.all.each do |dr|
  p [dr.document_id, dr.related_document_id]
  dr.create_inverse_relation
end
