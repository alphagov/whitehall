json.results_any? @editions.any?
json.set! :results do
  json.array! @editions do |id, document_id, title|
    json.id id
    json.document_id document_id
    json.title title
  end
end
