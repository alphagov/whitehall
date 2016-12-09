#discard draft attachments that have the incorrect content_id from
#publishing API
draft_html_attachment_content_ids = [
  '09b404ef-dfad-434f-975f-57d5d21d6b50',
  '7da74881-f5c3-4dc8-becd-4c78a49e6ac8',
  'dd93e284-5e3d-4b57-9e60-82b044473fdb'
]

draft_html_attachment_content_ids.each do |content_id|
  PublishingApiDiscardDraftWorker.new.perform(content_id, "en")
end

#republish the 'parent' documents (which will republish the attachments
#correctly)
parent_document_ids = [337544, 271122, 345564]

parent_document_ids.each do |document_id|
  PublishingApiDocumentRepublishingWorker.perform_async(document_id)
end
