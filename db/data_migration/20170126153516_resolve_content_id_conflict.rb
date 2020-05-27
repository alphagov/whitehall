# There are two documents sharing the same slug but with different
# content ids. One of them has no editions and is blocking the other
# from being republished in the publishing api.
# Removes the blocking document and uses its content id to avoid
# base path conflicts downstream.
[[312_378, 308_033], [326_641, 313_515]].each do |blocked_document_id, blocking_document_id|
  blocked_document = Document.find(blocked_document_id)
  blocking_document = Document.find(blocking_document_id)
  blocked_document.content_id = blocking_document.content_id
  blocked_document.save!
  blocking_document.destroy!
end
