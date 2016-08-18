document_collection = DocumentCollection.find_by(id: 640432)

if document_collection.present?
  document_collection.minor_change = true

  # Skip validation here, because normally document collections (editions) in a
  # superseded state cannot have their minor_change field modified.
  document_collection.save(validate: false)
else
  "Document Collection#640432 not found."
end
